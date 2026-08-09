// Sahay Location Tracking Service — Real GPS Broadcasting
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'firebase_dispatch_service.dart';
import '../providers/responder_state.dart';

class LocationTrackingService {
  final FirebaseDispatchService _firebaseService;
  final ResponderState _responderState;
  StreamSubscription<Position>? _positionStream;

  LocationTrackingService(this._firebaseService, this._responderState);

  Future<void> startTracking() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('Location services are disabled.');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint('Location permissions are denied');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      debugPrint('Location permissions permanently denied');
      return;
    }

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Update every 10 meters
    );

    Position? _lastPosition;

    _positionStream = Geolocator.getPositionStream(locationSettings: locationSettings).listen((Position position) {
      if (position.accuracy > 100) return;
      
      if (_lastPosition != null) {
        final distance = Geolocator.distanceBetween(
          _lastPosition!.latitude, _lastPosition!.longitude,
          position.latitude, position.longitude
        );
        if (distance < 10) return;
      }
      _lastPosition = position;

      // Update responder state with real GPS
      _responderState.updateLiveLocation(position.latitude, position.longitude);

      // Broadcast to Firestore — use real phone as doc ID
      final phone = _responderState.phone;
      _firebaseService.broadcastLocation(phone, position.latitude, position.longitude);

      // If on active mission, also update location in emergency document
      final emergencyId = _responderState.currentEmergencyId;
      if (emergencyId != null && phone.isNotEmpty) {
        _firebaseService.updateResponderLocationInEmergency(
          emergencyId, phone, position.latitude, position.longitude,
        );
      }
    });
  }

  void stopTracking() {
    if (_positionStream != null) {
      _positionStream!.cancel();
      _positionStream = null;
    }
  }
}
