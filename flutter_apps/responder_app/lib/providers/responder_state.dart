// Sahay Responder State — Real-World Profile & Mission Management
// No hardcoded data. All profile data comes from user registration.
// GPS comes from real device location via LocationTrackingService.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum MissionStatus {
  offline,
  standingBy,
  enRouteToScene,
  onScene,
  inTransitToHospital,
  handover,
  completed
}

class ResponderState extends ChangeNotifier {
  MissionStatus _currentStatus = MissionStatus.offline;
  bool _isActive = false;
  
  // Profile — loaded from SharedPreferences (user-registered)
  String _driverName = '';
  String _phone = '';
  String _ambulanceNumber = '';
  String _driverLicense = '';
  String _vehicleType = '';
  String _hospitalAffiliation = '';
  bool _isVerified = false;
  bool _isRegistered = false;

  // Mission Stats — from Firestore
  int _completedMissionsCount = 0;
  int _livesSaved = 0;
  
  // Current mission
  Map<String, dynamic>? _currentMissionData;
  String? _currentEmergencyId;
  
  // Real GPS position
  double _currentLat = 0.0;
  double _currentLng = 0.0;
  
  // Patient Vitals (entered by responder on-scene)
  Map<String, String> _patientVitals = {};

  // Selected Target Hospital
  Map<String, dynamic>? _selectedHospital;

  // Emergency stream
  StreamSubscription? _emergencySubscription;

  dynamic _locationService;

  // Getters
  MissionStatus get currentStatus => _currentStatus;
  bool get isActive => _isActive;
  bool get isRegistered => _isRegistered;
  String get driverName => _driverName;
  String get phone => _phone;
  String get ambulanceNumber => _ambulanceNumber;
  String get driverLicense => _driverLicense;
  String get vehicleType => _vehicleType;
  String get hospitalAffiliation => _hospitalAffiliation;
  bool get isVerified => _isVerified;

  int get completedMissionsCount => _completedMissionsCount;
  int get livesSaved => _livesSaved;

  Map<String, dynamic>? get currentMissionData => _currentMissionData;
  String? get currentEmergencyId => _currentEmergencyId;
  double get currentLat => _currentLat;
  double get currentLng => _currentLng;
  bool get hasLocation => _currentLat != 0.0 && _currentLng != 0.0;
  Map<String, String> get patientVitals => _patientVitals;
  Map<String, dynamic>? get selectedHospital => _selectedHospital;

  // Load saved profile from SharedPreferences
  Future<void> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    _isRegistered = prefs.getBool('resp_registered') ?? false;
    _driverName = prefs.getString('resp_name') ?? '';
    _phone = prefs.getString('resp_phone') ?? '';
    _ambulanceNumber = prefs.getString('resp_ambulance') ?? '';
    _driverLicense = prefs.getString('resp_license') ?? '';
    _vehicleType = prefs.getString('resp_vehicle_type') ?? '';
    _hospitalAffiliation = prefs.getString('resp_hospital') ?? '';
    _isVerified = prefs.getBool('resp_verified') ?? false;
    
    // Load stats from Firestore
    await _loadStatsFromFirestore();
    
    // Load active mission state if app was killed
    final activeId = prefs.getString('active_emergency_id');
    final activeStatus = prefs.getInt('active_mission_status');
    if (activeId != null && activeId.isNotEmpty && activeStatus != null) {
      _currentEmergencyId = activeId;
      _currentStatus = MissionStatus.values[activeStatus];
      _isActive = true;
    }

    notifyListeners();
  }

  Future<void> _saveMissionState() async {
    final prefs = await SharedPreferences.getInstance();
    if (_currentStatus != MissionStatus.offline && _currentStatus != MissionStatus.standingBy) {
      await prefs.setString('active_emergency_id', _currentEmergencyId ?? '');
      await prefs.setInt('active_mission_status', _currentStatus.index);
    } else {
      await prefs.remove('active_emergency_id');
      await prefs.remove('active_mission_status');
    }

  Future<void> _loadStatsFromFirestore() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('responders')
          .doc(_phone.isNotEmpty ? _phone : 'unknown')
          .get();
      if (doc.exists) {
        final data = doc.data()!;
        _completedMissionsCount = data['completedMissions'] ?? 0;
        _livesSaved = data['livesSaved'] ?? 0;
      }
    } catch (_) {
      // Stats loading is best-effort
    }
  }

  // Register responder — save to prefs + Firestore
  Future<void> registerResponder({
    required String name,
    required String phone,
    required String ambulanceNo,
    required String license,
    required String vehicleType,
    required String hospital,
  }) async {
    _driverName = name;
    _phone = phone;
    _ambulanceNumber = ambulanceNo;
    _driverLicense = license;
    _vehicleType = vehicleType;
    _hospitalAffiliation = hospital;
    _isVerified = true;
    _isRegistered = true;
    _isActive = true;
    _currentStatus = MissionStatus.standingBy;

    // Save to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('resp_registered', true);
    await prefs.setString('resp_name', name);
    await prefs.setString('resp_phone', phone);
    await prefs.setString('resp_ambulance', ambulanceNo);
    await prefs.setString('resp_license', license);
    await prefs.setString('resp_vehicle_type', vehicleType);
    await prefs.setString('resp_hospital', hospital);
    await prefs.setBool('resp_verified', true);

    // Save to Firestore
    try {
      await FirebaseFirestore.instance.collection('responders').doc(phone).set({
        'name': name,
        'phone': phone,
        'ambulanceNumber': ambulanceNo,
        'license': license,
        'vehicleType': vehicleType,
        'hospital': hospital,
        'isOnline': true,
        'registeredAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {}

    notifyListeners();
  }

  void updateVitals(String hr, String bp, String spo2, {String temp = ''}) {
    _patientVitals = {
      'hr': hr,
      'bp': bp,
      'spo2': spo2,
      if (temp.isNotEmpty) 'temp': temp,
    };
    notifyListeners();
  }

  void setSelectedHospital(Map<String, dynamic> hospital) {
    _selectedHospital = hospital;
    notifyListeners();
  }

  void setLocationService(dynamic service) {
    _locationService = service;
  }

  // Real GPS update from LocationTrackingService
  void updateLiveLocation(double lat, double lng) {
    _currentLat = lat;
    _currentLng = lng;
    notifyListeners();
  }

  void toggleActiveStatus() {
    _isActive = !_isActive;
    if (_isActive && _currentStatus == MissionStatus.offline) {
      _currentStatus = MissionStatus.standingBy;
      _locationService?.startTracking();
      // Update online status in Firestore
      _updateOnlineStatus(true);
    } else if (!_isActive) {
      _currentStatus = MissionStatus.offline;
      _currentMissionData = null;
      _currentEmergencyId = null;
      _locationService?.stopTracking();
      _updateOnlineStatus(false);
    }
    notifyListeners();
  }

  Future<void> _updateOnlineStatus(bool isOnline) async {
    if (_phone.isEmpty) return;
    try {
      await FirebaseFirestore.instance.collection('responders').doc(_phone).set({
        'isOnline': isOnline,
        'lastSeen': FieldValue.serverTimestamp(),
        if (_currentLat != 0) 'lastLocation': GeoPoint(_currentLat, _currentLng),
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  void assignMission(Map<String, dynamic> missionData, String emergencyId) {
    _currentMissionData = missionData;
    _currentEmergencyId = emergencyId;
    notifyListeners();
  }

  Future<void> acceptEmergency() async {
    _currentStatus = MissionStatus.enRouteToScene;
    if (_currentEmergencyId != null && _phone.isNotEmpty) {
      try {
        await FirebaseFirestore.instance
            .collection('emergencies')
            .doc(_currentEmergencyId)
            .update({
          'status': 'accepted',
          'responderPhone': _phone,
          'acceptedAt': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        debugPrint('Error accepting emergency: $e');
      }
    }
    _saveMissionState();
    notifyListeners();
  }

  void declineMission() {
    _emergencySubscription?.cancel();
    _currentStatus = MissionStatus.standingBy;
    _currentMissionData = null;
    _currentEmergencyId = null;
    _saveMissionState();
    notifyListeners();
  }

  void cancelMission() {
    _emergencySubscription?.cancel();
    _currentStatus = MissionStatus.standingBy;
    _currentMissionData = null;
    _currentEmergencyId = null;
    _patientVitals = {};
    _selectedHospital = null;
    _saveMissionState();
    notifyListeners();
  }

  void updateMissionPhase(String phase) {
    if (phase == 'on_scene') {
      _currentStatus = MissionStatus.onScene;
    } else if (phase == 'in_transit') {
      _currentStatus = MissionStatus.inTransitToHospital;
    } else if (phase == 'handover') {
      _currentStatus = MissionStatus.handover;
    }
    notifyListeners();
  }

  Future<void> completeMission() async {
    _completedMissionsCount += 1;
    _livesSaved += 1;
    _currentStatus = MissionStatus.standingBy;

    // Save to Firestore
    if (_phone.isNotEmpty) {
      try {
        await FirebaseFirestore.instance.collection('responders').doc(_phone).update({
          'completedMissions': _completedMissionsCount,
          'livesSaved': _livesSaved,
        });

        // Save mission to history
        if (_currentEmergencyId != null) {
          await FirebaseFirestore.instance
              .collection('responders')
              .doc(_phone)
              .collection('missionHistory')
              .add({
            'emergencyId': _currentEmergencyId,
            'completedAt': FieldValue.serverTimestamp(),
            'patientVitals': _patientVitals,
            'hospital': _selectedHospital?['name'] ?? '',
          });
        }
      } catch (_) {}
    }

    _currentMissionData = null;
    _currentEmergencyId = null;
    _patientVitals = {};
    _selectedHospital = null;
    _emergencySubscription?.cancel();
    _saveMissionState();
    notifyListeners();
  }

  void updateMissionStatus(MissionStatus newStatus) {
    _currentStatus = newStatus;
    if (newStatus == MissionStatus.completed) {
      completeMission();
    }
    notifyListeners();
  }

  Future<void> logout() async {
    _isRegistered = false;
    _isActive = false;
    _currentStatus = MissionStatus.offline;
    _driverName = '';
    _phone = '';
    _locationService?.stopTracking();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    notifyListeners();
  }

  @override
  void dispose() {
    _emergencySubscription?.cancel();
    super.dispose();
  }
}
