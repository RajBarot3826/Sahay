const { onDocumentCreated, onDocumentUpdated } = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");

admin.initializeApp();

exports.onEmergencyCreated = onDocumentCreated("emergencies/{emergencyId}", async (event) => {
  const snapshot = event.data;
  if (!snapshot) return;
  
  const emergencyData = snapshot.data();
  const emergencyId = event.params.emergencyId;
  const callerId = emergencyData.userId;
  
  try {
    // Query ALL responders from responders collection where isOnline == true
    const respondersRef = admin.firestore().collection('responders');
    const onlineRespondersSnapshot = await respondersRef.where('isOnline', '==', true).get();
    
    if (onlineRespondersSnapshot.empty) {
      console.log('No online responders found for emergency:', emergencyId);
      return;
    }
    
    const tokens = [];
    const responderDocs = [];
    
    onlineRespondersSnapshot.forEach(doc => {
      const data = doc.data();
      if (data.fcmToken) {
        tokens.push(data.fcmToken);
        responderDocs.push({ id: doc.id, token: data.fcmToken });
      }
    });
    
    if (tokens.length === 0) {
      console.log('No FCM tokens found for online responders.');
      return;
    }

    // Extract lat/lng from GeoPoint object (Firestore stores as GeoPoint, not separate fields)
    const location = emergencyData.location;
    const lat = location ? location.latitude.toString() : '0';
    const lng = location ? location.longitude.toString() : '0';

    const payload = {
      notification: {
        title: '🚨 EMERGENCY SOS',
        body: `${emergencyData.userName || 'Someone'} needs help! ${emergencyData.type || 'An'} emergency at their location.`
      },
      data: {
        type: 'new_emergency',
        emergencyId: emergencyId,
        emergencyType: emergencyData.type || 'unknown',
        callerName: emergencyData.userName || 'unknown',
        callerPhone: emergencyData.userPhone || 'unknown',
        latitude: lat,
        longitude: lng
      },
      android: {
        priority: 'high',
        notification: {
          channelId: 'sos_dispatch_channel',
          priority: 'max',
          visibility: 'public',
          sound: 'default',
          defaultVibrateTimings: true,
        }
      }
    };

    const message = {
      ...payload,
      tokens: tokens
    };

    const response = await admin.messaging().sendEachForMulticast(message);
    
    // Handle invalid tokens
    if (response.failureCount > 0) {
      const failedTokens = [];
      response.responses.forEach((resp, idx) => {
        if (!resp.success) {
          const error = resp.error;
          if (error.code === 'messaging/invalid-registration-token' ||
              error.code === 'messaging/registration-token-not-registered') {
            failedTokens.push(tokens[idx]);
          }
        }
      });
      
      // Clean up stale tokens in responders collection
      if (failedTokens.length > 0) {
        const batch = admin.firestore().batch();
        responderDocs.forEach(rd => {
          if (failedTokens.includes(rd.token)) {
            const ref = respondersRef.doc(rd.id);
            batch.update(ref, { fcmToken: admin.firestore.FieldValue.delete() });
          }
        });
        await batch.commit();
      }
    }
    
    // Write a notification record to the citizen's users/{userId}/notifications subcollection
    if (callerId) {
      await admin.firestore().collection('users').doc(callerId).collection('notifications').add({
        title: 'SOS Broadcasted',
        body: `Your emergency signal has been sent to ${tokens.length} responders.`,
        type: 'sos_sent',
        category: 'Alerts',
        read: false,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        emergencyId: emergencyId
      });
    }

  } catch (error) {
    console.error('Error in onEmergencyCreated:', error);
  }
});

exports.onEmergencyUpdated = onDocumentUpdated("emergencies/{emergencyId}", async (event) => {
  const before = event.data.before.data();
  const after = event.data.after.data();
  const emergencyId = event.params.emergencyId;
  const callerId = after.userId;

  if (!before || !after) return;
  
  if (before.status === after.status) return; // Only process status changes

  try {
    const callerDoc = await admin.firestore().collection('users').doc(callerId).get();
    const callerFcmToken = callerDoc.exists ? callerDoc.data().fcmToken : null;
    
    // acceptedResponders is an array of MAPS like {uid, name, phone, vehicleType, ...}
    const acceptedResponders = after.acceptedResponders || [];
    
    // Status changes logic
    // searching -> accepted
    if (before.status === 'searching' && after.status === 'accepted') {
      // Get the name of the first (or most recent) responder from the array
      const lastResponder = acceptedResponders.length > 0 
        ? acceptedResponders[acceptedResponders.length - 1] 
        : null;
      const responderName = lastResponder ? (lastResponder.name || 'A responder') : 'A responder';

      if (callerFcmToken) {
        const msg = {
          token: callerFcmToken,
          notification: {
            title: '✅ Responder Accepted',
            body: `${responderName} has accepted your emergency and is on the way.`
          },
          data: {
            type: 'emergency_accepted',
            emergencyId: emergencyId,
            targetUserId: callerId
          },
          android: {
            priority: 'high',
            notification: {
              channelId: 'sahay_updates_channel',
              priority: 'max',
              visibility: 'public',
              sound: 'default',
              defaultVibrateTimings: true,
            }
          }
        };
        await admin.messaging().send(msg).catch(err => console.log('Error sending to citizen:', err));
      }
      
      await admin.firestore().collection('users').doc(callerId).collection('notifications').add({
        title: 'Responder Accepted',
        body: `${responderName} has accepted your emergency.`,
        type: 'emergency_accepted',
        category: 'Updates',
        read: false,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        emergencyId: emergencyId
      });
    }
    
    // accepted -> resolved OR tracking -> resolved
    else if ((before.status === 'accepted' || before.status === 'tracking') && after.status === 'resolved') {
      // Send to CITIZEN
      if (callerFcmToken) {
        const msg = {
          token: callerFcmToken,
          notification: {
            title: '✅ Emergency Resolved',
            body: 'Your emergency has been marked as resolved.'
          },
          data: { type: 'emergency_resolved', emergencyId: emergencyId, targetUserId: callerId },
          android: {
            priority: 'high',
            notification: { channelId: 'sahay_updates_channel', priority: 'max', visibility: 'public', sound: 'default', defaultVibrateTimings: true }
          }
        };
        await admin.messaging().send(msg).catch(err => console.log('Error:', err));
      }
      
      await admin.firestore().collection('users').doc(callerId).collection('notifications').add({
        title: 'Emergency Resolved',
        body: 'Your emergency has been resolved.',
        type: 'emergency_resolved',
        category: 'Updates',
        read: false,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        emergencyId: emergencyId
      });
      
      // Send to accepted responders — acceptedResponders is an array of MAPS, extract phone
      if (acceptedResponders.length > 0) {
        for (const responder of acceptedResponders) {
          // Each responder is a map: {uid, name, phone, vehicleType, latitude, longitude, ...}
          const responderPhone = responder.phone || responder.uid;
          if (!responderPhone) continue;
          
          const rDoc = await admin.firestore().collection('responders').doc(responderPhone).get();
          if (rDoc.exists && rDoc.data().fcmToken) {
            const msg = {
              token: rDoc.data().fcmToken,
              notification: { title: '✅ Emergency Resolved', body: 'The emergency you accepted has been resolved.' },
              data: { type: 'emergency_resolved', emergencyId: emergencyId },
              android: { priority: 'high', notification: { channelId: 'mission_updates_channel', priority: 'max', visibility: 'public', sound: 'default', defaultVibrateTimings: true } }
            };
            await admin.messaging().send(msg).catch(err => console.log('Error:', err));
          }

          // Write notification to responder's subcollection
          await admin.firestore().collection('responders').doc(responderPhone).collection('notifications').add({
            title: 'Emergency Resolved',
            body: 'The emergency you accepted has been resolved.',
            type: 'emergency_resolved',
            category: 'Mission Updates',
            read: false,
            timestamp: admin.firestore.FieldValue.serverTimestamp(),
            emergencyId: emergencyId
          }).catch(err => console.log('Error writing responder notification:', err));
        }
      }
    }
    
    // searching -> cancelled OR accepted -> cancelled
    else if ((before.status === 'searching' || before.status === 'accepted') && after.status === 'cancelled') {
       const notifiedRespondersQuery = await admin.firestore().collection('responders').where('isOnline', '==', true).get();
       const notifiedTokens = [];
       const notifiedPhones = [];
       notifiedRespondersQuery.forEach(doc => {
           if(doc.data().fcmToken) {
             notifiedTokens.push(doc.data().fcmToken);
             notifiedPhones.push(doc.id);
           }
       });
       
       if (notifiedTokens.length > 0) {
           const message = {
              notification: {
                title: '❌ Emergency Cancelled',
                body: 'The emergency has been cancelled.'
              },
              data: {
                type: 'emergency_cancelled',
                emergencyId: emergencyId
              },
              android: {
                priority: 'high',
                notification: {
                  channelId: 'sos_dispatch_channel',
                  priority: 'max',
                  visibility: 'public',
                  sound: 'default',
                  defaultVibrateTimings: true,
                }
              },
              tokens: notifiedTokens
           };
           await admin.messaging().sendEachForMulticast(message).catch(err => console.log('Error cancelling:', err));
       }

       // Write notification to each online responder's subcollection
       for (const phone of notifiedPhones) {
         await admin.firestore().collection('responders').doc(phone).collection('notifications').add({
           title: 'Emergency Cancelled',
           body: 'An emergency in your area has been cancelled.',
           type: 'emergency_cancelled',
           category: 'Emergency',
           read: false,
           timestamp: admin.firestore.FieldValue.serverTimestamp(),
           emergencyId: emergencyId
         }).catch(err => console.log('Error writing responder cancel notification:', err));
       }
       
       if (callerId) {
         await admin.firestore().collection('users').doc(callerId).collection('notifications').add({
            title: 'Emergency Cancelled',
            body: 'Your emergency has been cancelled.',
            type: 'emergency_cancelled',
            category: 'Updates',
            read: false,
            timestamp: admin.firestore.FieldValue.serverTimestamp(),
            emergencyId: emergencyId
         });
       }
    }

  } catch (error) {
    console.error('Error in onEmergencyUpdated:', error);
  }
});
