// Sahay Real-World Firebase Emergency Service
// Handles all Firestore CRUD operations for SOS emergencies.
// Creates emergency documents, manages live location streams,
// and provides real-time listeners for responder acceptances.

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

class FirebaseEmergencyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Timer? _locationStreamTimer;
  StreamSubscription? _emergencyListener;

  /// Creates a new emergency document in Firestore.
  /// Returns the emergency document ID.
  Future<String?> createEmergency({
    required String type, // 'citizens', 'ambulance', 'both'
    required double latitude,
    required double longitude,
    required String userName,
    required String userPhone,
    String bloodGroup = '',
  }) async {
    try {
      final user = _auth.currentUser;

      final emergencyData = {
        'userId': user?.uid ?? 'guest_${DateTime.now().millisecondsSinceEpoch}',
        'userName': userName,
        'userPhone': userPhone,
        'bloodGroup': bloodGroup,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'searching', // searching → accepted → tracking → resolved → cancelled
        'type': type,
        'location': GeoPoint(latitude, longitude),
        'senderLiveLocation': GeoPoint(latitude, longitude),
        'currentRadiusKm': 1.0,
        'radiusHistory': [1.0],
        'radiusExpandedAt': FieldValue.serverTimestamp(),
        'minAcceptorsNeeded': 2,
        'acceptedResponders': [],
        'responderLiveLocations': {},
      };

      final docRef = await _firestore.collection('emergencies').add(emergencyData);

      // Write notification record for the citizen
      final notifUserId = user?.uid ?? '';
      if (notifUserId.isNotEmpty) {
        try {
          await _firestore
              .collection('users')
              .doc(notifUserId)
              .collection('notifications')
              .add({
            'title': 'SOS Triggered',
            'body': 'Emergency alert sent. Type: $type. Searching for nearby help...',
            'type': 'sos',
            'category': 'Alerts',
            'emergencyId': docRef.id,
            'timestamp': FieldValue.serverTimestamp(),
            'read': false,
          });
        } catch (_) {}
      }

      return docRef.id;
    } catch (e) {
      print('Error creating emergency: $e');
      // Return a local ID for offline mode
      return 'local_${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  /// Updates the search radius for an emergency.
  Future<void> updateRadius(String emergencyId, double newRadiusKm) async {
    try {
      await _firestore.collection('emergencies').doc(emergencyId).update({
        'currentRadiusKm': newRadiusKm,
        'radiusExpandedAt': FieldValue.serverTimestamp(),
        'radiusHistory': FieldValue.arrayUnion([newRadiusKm]),
      });
    } catch (e) {
      print('Error updating radius: $e');
    }
  }

  /// Listens for real-time changes to an emergency document.
  /// Returns a stream of emergency data snapshots.
  Stream<DocumentSnapshot<Map<String, dynamic>>> listenToEmergency(String emergencyId) {
    return _firestore.collection('emergencies').doc(emergencyId).snapshots();
  }

  /// Starts streaming the sender's live GPS location to Firestore every 5 seconds.
  void startLocationStream(String emergencyId) {
    _locationStreamTimer?.cancel();
    _locationStreamTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) async {
        try {
          final position = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              timeLimit: Duration(seconds: 4),
            ),
          );

          await _firestore.collection('emergencies').doc(emergencyId).update({
            'senderLiveLocation': GeoPoint(position.latitude, position.longitude),
            'senderLocationUpdatedAt': FieldValue.serverTimestamp(),
          });
        } catch (e) {
          // Silently fail — location update is best-effort
        }
      },
    );
  }

  /// Stops the live location stream.
  void stopLocationStream() {
    _locationStreamTimer?.cancel();
    _locationStreamTimer = null;
  }

  /// Resolves (completes) an active emergency.
  Future<bool> resolveEmergency(String emergencyId) async {
    try {
      await _firestore.collection('emergencies').doc(emergencyId).update({
        'status': 'resolved',
        'resolvedAt': FieldValue.serverTimestamp(),
      });
      stopLocationStream();
      return true;
    } catch (e) {
      print('Error resolving emergency: $e');
      return false;
    }
  }

  /// Cancels an active emergency.
  Future<bool> cancelEmergency(String emergencyId) async {
    try {
      await _firestore.collection('emergencies').doc(emergencyId).update({
        'status': 'cancelled',
        'cancelledAt': FieldValue.serverTimestamp(),
      });
      stopLocationStream();
      return true;
    } catch (e) {
      print('Error cancelling emergency: $e');
      return false;
    }
  }

  /// Gets a single emergency document by ID.
  Future<Map<String, dynamic>?> getEmergency(String emergencyId) async {
    try {
      final doc = await _firestore.collection('emergencies').doc(emergencyId).get();
      return doc.data();
    } catch (e) {
      return null;
    }
  }

  /// Gets all active emergencies for the current user.
  Future<List<Map<String, dynamic>>> getActiveEmergencies() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      final snapshot = await _firestore
          .collection('emergencies')
          .where('userId', isEqualTo: user.uid)
          .where('status', whereIn: ['searching', 'accepted', 'tracking'])
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      return snapshot.docs.map((d) => {'id': d.id, ...d.data()}).toList();
    } catch (e) {
      return [];
    }
  }

  /// Cleanup all listeners and timers.
  void dispose() {
    stopLocationStream();
    _emergencyListener?.cancel();
  }
}
