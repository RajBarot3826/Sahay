// Sahay Emergency Provider — Real-World SOS State Machine
// Manages the complete SOS lifecycle:
// inactive → countdown → choosing → searching → accepted → tracking → resolved
//
// Integrates with Firestore for real-time emergency data,
// expanding radius service for notification expansion,
// and GPS streaming for live location tracking.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/firebase_emergency_service.dart';
import '../services/sos_radius_service.dart';

enum SosState {
  inactive,    // No emergency
  countdown,   // 3-second countdown running
  choosing,    // User choosing SOS type (citizens/ambulance/both)
  searching,   // Searching for responders (expanding radius)
  accepted,    // Minimum 2 responders accepted
  tracking,    // Live tracking active
  resolved,    // Emergency resolved
  cancelled,   // Emergency cancelled
}

class EmergencyProvider extends ChangeNotifier {
  final FirebaseEmergencyService _emergencyService = FirebaseEmergencyService();
  final SosRadiusService _radiusService = SosRadiusService();

  // State
  SosState _state = SosState.inactive;
  String? _emergencyId;
  String _sosType = ''; // 'citizens', 'ambulance', 'both'
  
  // Countdown
  int _countdownSeconds = 3;
  Timer? _countdownTimer;

  // Radius & Search
  double _currentRadiusKm = 1.0;
  int _currentRadiusIndex = 0;
  Timer? _searchTimer;

  // Acceptances
  int _acceptedCount = 0;
  List<Map<String, dynamic>> _acceptedResponders = [];

  // Location
  Position? _userPosition;
  
  // Firestore listener
  StreamSubscription? _emergencyListener;

  // Getters
  SosState get state => _state;
  bool get isEmergencyActive => _state == SosState.searching || _state == SosState.accepted || _state == SosState.tracking;
  bool get isSearching => _state == SosState.searching;
  bool get isAccepted => _state == SosState.accepted || _state == SosState.tracking;
  String? get emergencyId => _emergencyId;
  String get sosType => _sosType;
  int get countdownSeconds => _countdownSeconds;
  double get currentRadiusKm => _currentRadiusKm;
  int get currentRadiusIndex => _currentRadiusIndex;
  int get acceptedCount => _acceptedCount;
  List<Map<String, dynamic>> get acceptedResponders => _acceptedResponders;
  Position? get userPosition => _userPosition;

  String get eta {
    if (_acceptedResponders.isEmpty) return 'Searching...';
    final nearest = _acceptedResponders.first;
    final etaMins = nearest['etaMins'] ?? nearest['distanceKm'] ?? 5;
    return '$etaMins mins';
  }

  String get statusText {
    switch (_state) {
      case SosState.inactive: return 'No Active Emergency';
      case SosState.countdown: return 'SOS Activating...';
      case SosState.choosing: return 'Choose Alert Type';
      case SosState.searching: return 'Searching (${_currentRadiusKm.toStringAsFixed(0)} km radius)';
      case SosState.accepted: return '$_acceptedCount Responders En Route';
      case SosState.tracking: return 'Live Tracking Active';
      case SosState.resolved: return 'Emergency Resolved';
      case SosState.cancelled: return 'Emergency Cancelled';
    }
  }

  // ─────────────────────────────────────────────────────────
  // STEP 1: Start 3-second countdown
  // ─────────────────────────────────────────────────────────
  void startCountdown() {
    if (_state != SosState.inactive) return;
    _state = SosState.countdown;
    _countdownSeconds = 3;
    notifyListeners();

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _countdownSeconds--;
      notifyListeners();

      if (_countdownSeconds <= 0) {
        timer.cancel();
        _countdownTimer = null;
        _state = SosState.choosing;
        notifyListeners();
      }
    });
  }

  /// Cancel the countdown before it completes.
  void cancelCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
    _state = SosState.inactive;
    _countdownSeconds = 3;
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────
  // STEP 2: User selects SOS type and triggers emergency
  // ─────────────────────────────────────────────────────────
  Future<void> triggerSOS(String type, {String userName = '', String userPhone = '', String bloodGroup = ''}) async {
    if (isEmergencyActive) return;
    _sosType = type;
    _state = SosState.searching;
    _currentRadiusKm = 1.0;
    _currentRadiusIndex = 0;
    _acceptedCount = 0;
    _acceptedResponders = [];
    notifyListeners();

    // Get user's real GPS location
    try {
      _userPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (_) {
      try {
        _userPosition = await Geolocator.getLastKnownPosition();
      } catch (_) {}
    }

    final double lat = _userPosition?.latitude ?? 21.7645;
    final double lng = _userPosition?.longitude ?? 72.1519;

    // Create emergency in Firestore
    _emergencyId = await _emergencyService.createEmergency(
      type: type,
      latitude: lat,
      longitude: lng,
      userName: userName.isNotEmpty ? userName : 'Citizen',
      userPhone: userPhone,
      bloodGroup: bloodGroup,
    );

    if (_emergencyId != null) {
      // Start live GPS streaming
      _emergencyService.startLocationStream(_emergencyId!);

      // Start expanding radius search
      _setupRadiusCallbacks();
      _radiusService.startExpandingSearch(_emergencyId!);

      // Search timeout
      _searchTimer?.cancel();
      _searchTimer = Timer(const Duration(minutes: 10), () {
        if (_state == SosState.searching) {
          cancelSOS();
        }
      });

      // Listen for emergency document changes
      _listenToEmergency();
    }

    notifyListeners();
  }

  /// Setup callbacks for radius expansion events.
  void _setupRadiusCallbacks() {
    _radiusService.onRadiusExpanded = (radiusKm, index) {
      _currentRadiusKm = radiusKm;
      _currentRadiusIndex = index;
      notifyListeners();
    };

    _radiusService.onAcceptanceUpdate = (acceptedCount, responders) {
      _acceptedCount = acceptedCount;
      _acceptedResponders = responders;
      notifyListeners();
    };

    _radiusService.onMinAcceptorsReached = () {
      _state = SosState.accepted;
      notifyListeners();

      // Transition to tracking after a brief delay
      Future.delayed(const Duration(seconds: 2), () {
        if (_state == SosState.accepted) {
          _state = SosState.tracking;
          notifyListeners();
        }
      });
    };

    _radiusService.onMaxRadiusReached = () {
      // Max radius reached but not enough acceptors — keep searching
      notifyListeners();
    };
  }

  /// Listen to real-time changes on the emergency document.
  void _listenToEmergency() {
    if (_emergencyId == null) return;

    _emergencyListener?.cancel();
    _emergencyListener = _emergencyService
        .listenToEmergency(_emergencyId!)
        .listen((snapshot) {
      if (!snapshot.exists) return;

      final data = snapshot.data();
      if (data == null) return;

      // Update accepted responders from Firestore
      final List<dynamic> accepted = data['acceptedResponders'] ?? [];
      _acceptedCount = accepted.length;
      _acceptedResponders = accepted.map((r) => Map<String, dynamic>.from(r)).toList();

      // Update radius
      _currentRadiusKm = (data['currentRadiusKm'] as num?)?.toDouble() ?? _currentRadiusKm;

      // Check status changes (could be changed by responder app)
      final String status = data['status'] ?? 'searching';
      if (status == 'accepted' && _state == SosState.searching) {
        _state = SosState.accepted;
        _radiusService.stop();
      } else if (status == 'resolved' && _state != SosState.resolved) {
        _state = SosState.resolved;
        _cleanup();
      } else if (status == 'cancelled' && _state != SosState.cancelled) {
        _state = SosState.cancelled;
        _cleanup();
      }

      notifyListeners();
    });
  }

  // ─────────────────────────────────────────────────────────
  // STEP 3: Cancel / Resolve emergency
  // ─────────────────────────────────────────────────────────
  Future<void> cancelSOS() async {
    if (_emergencyId != null) {
      await _emergencyService.cancelEmergency(_emergencyId!);
    }
    _state = SosState.cancelled;
    _cleanup();
    notifyListeners();

    // Reset to inactive after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      _state = SosState.inactive;
      notifyListeners();
    });
  }

  Future<void> resolveSOS() async {
    if (_emergencyId != null) {
      await _emergencyService.resolveEmergency(_emergencyId!);
    }
    _state = SosState.resolved;
    _cleanup();
    notifyListeners();

    // Reset to inactive after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      _state = SosState.inactive;
      notifyListeners();
    });
  }

  /// Old API compatibility — calls triggerSOS with 'both' type.
  Future<void> activateSOS() async {
    startCountdown();
  }

  /// Cleanup all timers and listeners.
  void _cleanup() {
    _radiusService.stop();
    _emergencyService.stopLocationStream();
    _emergencyListener?.cancel();
    _emergencyListener = null;
    _countdownTimer?.cancel();
    _countdownTimer = null;
    _searchTimer?.cancel();
    _searchTimer = null;
  }

  @override
  void dispose() {
    _cleanup();
    _radiusService.dispose();
    _emergencyService.dispose();
    super.dispose();
  }
}
