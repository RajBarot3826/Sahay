// Sahay Firebase Dispatch Service — Real-World Emergency Integration
// Matches citizen_app's Firestore schema for cross-device SOS.
// Listens for emergencies with status 'searching', accepts via arrayUnion.

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math' show cos, sqrt, asin;
import 'package:flutter/foundation.dart';

class FirebaseDispatchService {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  // Listen for active emergencies that need responders
  // Matches citizen_app's schema: status = 'searching' or 'accepted' (still needs more)
  Stream<List<Map<String, dynamic>>> listenForEmergencies() {
    try {
      return _firestore
          .collection('emergencies')
          .where('status', whereIn: ['searching', 'accepted'])
          .orderBy('timestamp', descending: true)
          .limit(10)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList();
      }).handleError((e) {
        debugPrint('Firebase listen error: $e');
        return <Map<String, dynamic>>[];
      });
    } catch (e) {
      debugPrint('Firebase stream init error: $e');
      return Stream.value(<Map<String, dynamic>>[]);
    }
  }

  // Listen for a specific emergency document changes
  Stream<Map<String, dynamic>?> listenToEmergency(String emergencyId) {
    return _firestore
        .collection('emergencies')
        .doc(emergencyId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      final data = doc.data()!;
      data['id'] = doc.id;
      return data;
    });
  }

  // Accept a mission — adds responder to acceptedResponders array
  // Matches citizen_app's schema: acceptedResponders is an array of maps
  Future<void> acceptMission({
    required String emergencyId,
    required String responderPhone,
    required String responderName,
    required String vehicleType,
    required double responderLat,
    required double responderLng,
  }) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final docRef = _firestore.collection('emergencies').doc(emergencyId);
        final snapshot = await transaction.get(docRef);
        
        if (!snapshot.exists) {
          throw Exception("Emergency does not exist!");
        }
        
        final data = snapshot.data()!;
        if (data['status'] != 'searching' && data['status'] != 'accepted') {
          throw Exception("Emergency already handled");
        }

        double emLat = data['latitude'] ?? responderLat;
        double emLng = data['longitude'] ?? responderLng;
        
        double distanceKm = _calculateDistance(responderLat, responderLng, emLat, emLng);
        int etaMins = (distanceKm / 30 * 60).ceil().clamp(1, 60);

        final responderData = {
          'uid': responderPhone,
          'name': responderName,
          'phone': responderPhone,
          'vehicleType': vehicleType,
          'latitude': responderLat,
          'longitude': responderLng,
          'distanceKm': distanceKm,
          'etaMins': etaMins,
          'acceptedAt': Timestamp.now(),
        };

        transaction.update(docRef, {
          'acceptedResponders': FieldValue.arrayUnion([responderData]),
          'status': 'accepted',
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
      debugPrint('Mission accepted: $emergencyId by $responderName');
    } catch (e) {
      debugPrint('Error accepting mission: $e');
      rethrow;
    }
  }

  Future<void> declineEmergency(String emergencyId, String responderPhone) async {
    try {
      await _firestore.collection('emergencies').doc(emergencyId).collection('declines').add({
        'responderPhone': responderPhone,
        'declinedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error declining emergency: $e');
    }
  }

  // Update mission status (on_scene, in_transit, resolved)
  Future<void> updateMissionStatus(String emergencyId, String newStatus) async {
    try {
      await _firestore.collection('emergencies').doc(emergencyId).update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error updating mission status: $e');
    }
  }

  // Broadcast responder's live GPS location
  Future<void> broadcastLocation(String responderPhone, double lat, double lng) async {
    if (responderPhone.isEmpty) return;
    try {
      await _firestore.collection('responders').doc(responderPhone).update({
        'lastLocation': GeoPoint(lat, lng),
        'lastLocationUpdate': FieldValue.serverTimestamp(),
        'isOnline': true,
      });
    } catch (e) {
      // Try set if doc doesn't exist
      try {
        await _firestore.collection('responders').doc(responderPhone).set({
          'lastLocation': GeoPoint(lat, lng),
          'lastLocationUpdate': FieldValue.serverTimestamp(),
          'isOnline': true,
        }, SetOptions(merge: true));
      } catch (_) {}
    }
  }

  // Also update live location in the emergency document (for citizen to see)
  Future<void> updateResponderLocationInEmergency(
    String emergencyId,
    String responderPhone,
    double lat,
    double lng,
  ) async {
    try {
      await _firestore.collection('emergencies').doc(emergencyId).update({
        'responderLiveLocations.$responderPhone': {
          'lat': lat,
          'lng': lng,
          'updatedAt': Timestamp.now(),
        },
      });
    } catch (e) {
      debugPrint('Error updating responder location in emergency: $e');
    }
  }

  // Get past missions for a responder
  Future<List<Map<String, dynamic>>> getMissionHistory(String responderPhone) async {
    try {
      final snapshot = await _firestore
          .collection('responders')
          .doc(responderPhone)
          .collection('missionHistory')
          .orderBy('completedAt', descending: true)
          .limit(50)
          .get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      debugPrint('Error getting mission history: $e');
      return [];
    }
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 - c((lat2 - lat1) * p)/2 + 
            c(lat1 * p) * c(lat2 * p) * 
            (1 - c((lon2 - lon1) * p))/2;
    return 12742 * asin(sqrt(a));
  }
}
