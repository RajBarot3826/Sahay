import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../services/hospital_service.dart';

/// Global location + hospital provider.
/// Fetches user's real GPS location and nearby hospitals
/// as soon as the app opens — works anywhere in the world.
class LocationProvider extends ChangeNotifier {
  Position? _currentPosition;
  List<HospitalModel> _hospitals = [];
  bool _isLoadingLocation = false;
  bool _isLoadingHospitals = false;
  String? _locationError;
  String? _hospitalError;
  DateTime? _lastFetchTime;

  // Getters
  Position? get currentPosition => _currentPosition;
  List<HospitalModel> get hospitals => _hospitals;
  bool get isLoadingLocation => _isLoadingLocation;
  bool get isLoadingHospitals => _isLoadingHospitals;
  bool get isLoading => _isLoadingLocation || _isLoadingHospitals;
  String? get locationError => _locationError;
  String? get hospitalError => _hospitalError;
  bool get hasLocation => _currentPosition != null;
  bool get hasHospitals => _hospitals.isNotEmpty;
  DateTime? get lastFetchTime => _lastFetchTime;

  double get latitude => _currentPosition?.latitude ?? 0.0;
  double get longitude => _currentPosition?.longitude ?? 0.0;

  /// Call this once from Dashboard initState().
  /// Automatically fetches location → then hospitals.
  Future<void> initialize() async {
    // Don't re-fetch if we already have data less than 5 minutes old
    if (_currentPosition != null && _lastFetchTime != null) {
      final elapsed = DateTime.now().difference(_lastFetchTime!);
      if (elapsed.inMinutes < 5) return;
    }

    await _fetchLocation();
    if (_currentPosition != null) {
      await _fetchHospitals();
    }
  }

  /// Manually refresh — re-fetches location and hospitals.
  Future<void> refresh() async {
    _lastFetchTime = null; // Force refresh
    await _fetchLocation();
    if (_currentPosition != null) {
      await _fetchHospitals();
    }
  }

  /// Step 1: Get user's real GPS location.
  Future<void> _fetchLocation() async {
    _isLoadingLocation = true;
    _locationError = null;
    notifyListeners();

    try {
      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permission permanently denied. Please enable in Settings.');
      }
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied. Tap to allow location access.');
      }

      // Check GPS enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('GPS is disabled. Please enable location services.');
      }

      // Get high-accuracy position
      try {
        _currentPosition = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 15),
          ),
        );
      } catch (_) {
        // Fallback: medium accuracy
        try {
          _currentPosition = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.medium,
              timeLimit: Duration(seconds: 10),
            ),
          );
        } catch (_) {
          // Fallback: last known
          _currentPosition = await Geolocator.getLastKnownPosition();
        }
      }

      if (_currentPosition == null) {
        throw Exception('Could not determine location. Check GPS and try again.');
      }

      _locationError = null;
    } catch (e) {
      _locationError = e.toString().replaceAll('Exception: ', '');
    }

    _isLoadingLocation = false;
    notifyListeners();
  }

  /// Step 2: Fetch real hospitals from Overpass API using current GPS.
  Future<void> _fetchHospitals() async {
    if (_currentPosition == null) return;

    _isLoadingHospitals = true;
    _hospitalError = null;
    notifyListeners();

    try {
      final service = HospitalService();
      _hospitals = await service.getNearbyHospitalsFromPosition(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );
      _lastFetchTime = DateTime.now();
      _hospitalError = null;
    } catch (e) {
      _hospitalError = e.toString().replaceAll('Exception: ', '');
    }

    _isLoadingHospitals = false;
    notifyListeners();
  }
}
