// Sahay SOS Expanding Radius Service
// Manages the radius expansion logic: 1km → 5km → 10km → 20km → 40km → 80km
// Each radius level waits 15 seconds for minimum 2 acceptors before expanding.

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

class SosRadiusService {
  static const List<double> radiusLevels = [1.0, 5.0, 10.0, 20.0, 40.0, 80.0];
  static const int expandIntervalSeconds = 15;
  static const int minAcceptors = 2;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Timer? _expandTimer;
  StreamSubscription? _acceptanceListener;
  int _currentRadiusIndex = 0;
  String? _emergencyId;
  bool _isStopped = false;

  // Callbacks
  Function(double radiusKm, int radiusIndex)? onRadiusExpanded;
  Function(int acceptedCount, List<Map<String, dynamic>> responders)? onAcceptanceUpdate;
  Function()? onMinAcceptorsReached;
  Function()? onMaxRadiusReached;

  /// Start the expanding radius search for an emergency.
  void startExpandingSearch(String emergencyId) {
    _emergencyId = emergencyId;
    _currentRadiusIndex = 0;
    _isStopped = false;

    // Set initial radius
    _updateRadiusInFirestore(radiusLevels[0]);

    // Start listening for acceptances
    _listenForAcceptances();

    // Start the expansion timer
    _startExpansionTimer();
  }

  /// Stop the expanding radius search.
  void stop() {
    _isStopped = true;
    _expandTimer?.cancel();
    _expandTimer = null;
    _acceptanceListener?.cancel();
    _acceptanceListener = null;
  }

  /// Starts a periodic timer that expands the radius every 15 seconds.
  void _startExpansionTimer() {
    _expandTimer?.cancel();
    _expandTimer = Timer.periodic(
      const Duration(seconds: expandIntervalSeconds),
      (timer) {
        if (_isStopped) {
          timer.cancel();
          return;
        }

        _currentRadiusIndex++;

        if (_currentRadiusIndex >= radiusLevels.length) {
          // Maximum radius reached
          timer.cancel();
          onMaxRadiusReached?.call();
          return;
        }

        final newRadius = radiusLevels[_currentRadiusIndex];
        _updateRadiusInFirestore(newRadius);
        onRadiusExpanded?.call(newRadius, _currentRadiusIndex);
      },
    );
  }

  /// Updates the current search radius in Firestore.
  Future<void> _updateRadiusInFirestore(double radiusKm) async {
    if (_emergencyId == null) return;

    try {
      await _firestore.collection('emergencies').doc(_emergencyId).update({
        'currentRadiusKm': radiusKm,
        'radiusExpandedAt': FieldValue.serverTimestamp(),
        'radiusHistory': FieldValue.arrayUnion([radiusKm]),
      });
    } catch (e) {
      print('Error updating radius: $e');
    }
  }

  /// Listens for responder acceptances in real-time.
  void _listenForAcceptances() {
    if (_emergencyId == null) return;

    _acceptanceListener?.cancel();
    _acceptanceListener = _firestore
        .collection('emergencies')
        .doc(_emergencyId)
        .snapshots()
        .listen((snapshot) {
      if (_isStopped || !snapshot.exists) return;

      final data = snapshot.data();
      if (data == null) return;

      final List<dynamic> accepted = data['acceptedResponders'] ?? [];
      final int acceptedCount = accepted.length;

      // Notify about acceptance update
      onAcceptanceUpdate?.call(
        acceptedCount,
        accepted.map((r) => Map<String, dynamic>.from(r)).toList(),
      );

      // Check if minimum acceptors reached
      if (acceptedCount >= minAcceptors) {
        // Stop expanding — enough responders accepted
        _expandTimer?.cancel();
        _expandTimer = null;

        // Update status to "accepted" so other devices dismiss the notification
        _firestore.collection('emergencies').doc(_emergencyId).update({
          'status': 'accepted',
          'acceptedAt': FieldValue.serverTimestamp(),
        });

        onMinAcceptorsReached?.call();
      }
    });
  }

  /// Get the current radius level.
  double get currentRadius =>
      _currentRadiusIndex < radiusLevels.length
          ? radiusLevels[_currentRadiusIndex]
          : radiusLevels.last;

  /// Get the current radius index.
  int get currentRadiusIndex => _currentRadiusIndex;

  /// Dispose resources.
  void dispose() {
    stop();
  }
}
