import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class HospitalModel {
  final String name;
  final double distanceKm;
  final LatLng location;
  final int etaMins;
  final String type;
  final bool isOpen24x7;
  final int icuBeds;
  final String phone;
  final String category; // 'Govt.', 'Private', 'Trauma'
  final String address;
  final String openingHours;

  HospitalModel({
    required this.name,
    required this.distanceKm,
    required this.location,
    required this.etaMins,
    required this.type,
    required this.isOpen24x7,
    required this.icuBeds,
    required this.phone,
    required this.category,
    this.address = '',
    this.openingHours = '24/7',
  });
}

class HospitalService {
  static const String _overpassUrl1 = 'https://overpass-api.de/api/interpreter';
  static const String _overpassUrl2 = 'https://overpass.kumi.systems/api/interpreter';

  /// Returns user's current accurate GPS position.
  /// Falls back to last known position, then to a default if everything fails.
  Future<Position> _getAccuratePosition() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permission permanently denied. Please enable it in Settings.');
    }
    if (permission == LocationPermission.denied) {
      throw Exception('Location permission denied. We need your location to find nearby hospitals.');
    }

    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled. Please enable GPS.');
    }

    // Try high-accuracy current position first
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
    } catch (_) {}

    // Fallback: try medium accuracy
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (_) {}

    // Fallback: last known position
    Position? lastPos = await Geolocator.getLastKnownPosition();
    if (lastPos != null) {
      return lastPos;
    }

    throw Exception('Could not determine your location. Please check GPS settings and try again.');
  }

  /// Determines if a hospital is 24/7 based on OSM tags.
  bool _is24Hours(Map<String, dynamic> tags) {
    final String openingHours = (tags['opening_hours'] ?? '').toString().toLowerCase();
    final String emergency = (tags['emergency'] ?? '').toString().toLowerCase();
    final String healthcareFacilityType = (tags['healthcare:speciality'] ?? '').toString().toLowerCase();
    final String amenity = (tags['amenity'] ?? '').toString().toLowerCase();

    // Explicit 24/7 indicators
    if (openingHours.contains('24/7') ||
        openingHours.contains('24 hours') ||
        openingHours.contains('mo-su 00:00-24:00') ||
        openingHours.contains('00:00-24:00') ||
        openingHours.contains('24h')) {
      return true;
    }

    // Emergency department = always open
    if (emergency == 'yes' || emergency == 'true') {
      return true;
    }

    // Hospitals (not clinics) are generally 24/7 in India
    if (amenity == 'hospital') {
      // If no opening_hours tag exists, assume 24/7 for hospitals
      if (openingHours.isEmpty) {
        return true;
      }
    }

    return false;
  }

  /// Categorizes hospital based on name and tags.
  String _categorize(String name, Map<String, dynamic> tags) {
    final nameLower = name.toLowerCase();
    final operator = (tags['operator'] ?? '').toString().toLowerCase();
    final operatorType = (tags['operator:type'] ?? '').toString().toLowerCase();

    if (operatorType == 'government' ||
        operatorType == 'public' ||
        operator.contains('government') ||
        nameLower.contains('civil') ||
        nameLower.contains('govt') ||
        nameLower.contains('general hospital') ||
        nameLower.contains('district') ||
        nameLower.contains('sub-district') ||
        nameLower.contains('community health') ||
        nameLower.contains('phc') ||
        nameLower.contains('chc')) {
      return 'Govt.';
    }

    if (nameLower.contains('trauma') ||
        (tags['emergency'] ?? '') == 'yes') {
      return 'Trauma';
    }

    return 'Private';
  }

  /// Determines hospital type description.
  String _getHospitalType(String name, String category, Map<String, dynamic> tags) {
    final speciality = (tags['healthcare:speciality'] ?? '').toString();
    final emergency = (tags['emergency'] ?? '').toString();

    if (emergency == 'yes') {
      if (category == 'Govt.') return 'Govt. Emergency & Trauma Center';
      return '24/7 ER & Emergency Care';
    }

    if (speciality.isNotEmpty) {
      return '24/7 ${speciality.replaceAll(';', ', ')} Hospital';
    }

    if (category == 'Govt.') return 'Govt. General Hospital';
    if (category == 'Trauma') return '24/7 Trauma Center';
    return '24/7 Multi-Specialty Hospital';
  }

  /// Extracts phone number from OSM tags.
  String _getPhone(Map<String, dynamic> tags) {
    return tags['phone'] ?? tags['contact:phone'] ?? tags['emergency_phone'] ?? '108';
  }

  /// Extracts address from OSM tags.
  String _getAddress(Map<String, dynamic> tags) {
    final parts = <String>[];
    if (tags['addr:street'] != null) parts.add(tags['addr:street']);
    if (tags['addr:city'] != null) parts.add(tags['addr:city']);
    if (tags['addr:district'] != null) parts.add(tags['addr:district']);
    if (tags['addr:state'] != null) parts.add(tags['addr:state']);
    if (parts.isEmpty && tags['addr:full'] != null) return tags['addr:full'];
    return parts.join(', ');
  }

  /// Fetches real nearby hospitals — gets GPS internally.
  Future<List<HospitalModel>> getNearbyHospitals() async {
    final Position position = await _getAccuratePosition();
    return getNearbyHospitalsFromPosition(position.latitude, position.longitude);
  }

  /// Fetches real nearby hospitals from a given GPS position.
  /// Use this when you already have the user's coordinates (e.g. from LocationProvider).
  Future<List<HospitalModel>> getNearbyHospitalsFromPosition(double lat, double lng) async {
    List<HospitalModel> hospitals = [];
    Set<String> processedNames = {};
    final distanceCalc = const Distance();

    // Query Overpass API for hospitals & clinics within 50km
    final query = '''
    [out:json][timeout:25];
    (
      node(around:50000,$lat,$lng)[amenity=hospital];
      way(around:50000,$lat,$lng)[amenity=hospital];
      relation(around:50000,$lat,$lng)[amenity=hospital];
      node(around:50000,$lat,$lng)[healthcare=hospital];
      way(around:50000,$lat,$lng)[healthcare=hospital];
      node(around:50000,$lat,$lng)[amenity=clinic]["opening_hours"~"24"];
      node(around:50000,$lat,$lng)[emergency=yes];
    );
    out center tags;
    ''';

    bool fetchedFromApi = false;

    for (String serverUrl in [_overpassUrl1, _overpassUrl2]) {
      if (fetchedFromApi) break;

      try {
        final response = await http.post(
          Uri.parse(serverUrl),
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'User-Agent': 'SahayApp/1.0 (Emergency Hospital Finder)',
            'Accept': '*/*',
          },
          body: {'data': query},
        ).timeout(const Duration(seconds: 30));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final elements = data['elements'] as List?;

          if (elements != null && elements.isNotEmpty) {
            fetchedFromApi = true;

            for (final el in elements) {
              final tags = el['tags'] as Map<String, dynamic>?;
              if (tags == null || tags['name'] == null) continue;

              final String name = tags['name'];
              final String nameKey = name.toLowerCase().trim();

              // Skip duplicates
              if (processedNames.contains(nameKey)) continue;

              // Get coordinates (node vs way/relation)
              double? hLat, hLng;
              if (el['lat'] != null && el['lon'] != null) {
                hLat = (el['lat'] as num).toDouble();
                hLng = (el['lon'] as num).toDouble();
              } else if (el['center'] != null) {
                hLat = (el['center']['lat'] as num).toDouble();
                hLng = (el['center']['lon'] as num).toDouble();
              }
              if (hLat == null || hLng == null) continue;

              // Check if 24/7
              if (!_is24Hours(tags)) continue;

              // Calculate distance
              final double distMeters = distanceCalc.as(
                LengthUnit.Meter,
                LatLng(lat, lng),
                LatLng(hLat, hLng),
              );
              final double distKm = double.parse((distMeters / 1000.0).toStringAsFixed(1));

              // Only include within 50km
              if (distKm > 50.0) continue;

              // Calculate realistic ETA (avg 40 km/h on Indian roads)
              final int eta = max(1, (distKm * 1.5).ceil());

              final String category = _categorize(name, tags);
              final String hospitalType = _getHospitalType(name, category, tags);
              final String phone = _getPhone(tags);
              final String address = _getAddress(tags);
              final String openingHours = tags['opening_hours'] ?? '24/7';

              // Estimate ICU beds based on hospital type/size
              final int beds = tags['beds'] != null
                  ? int.tryParse(tags['beds'].toString()) ?? 5
                  : (category == 'Govt.' ? 12 : 6);

              processedNames.add(nameKey);
              hospitals.add(HospitalModel(
                name: name,
                distanceKm: distKm,
                location: LatLng(hLat, hLng),
                etaMins: eta,
                type: hospitalType,
                isOpen24x7: true,
                icuBeds: beds,
                phone: phone,
                category: category,
                address: address,
                openingHours: openingHours,
              ));
            }
          }
        }
      } catch (_) {
        // Try next server
      }
    }

    // Sort by distance: nearest first → farthest last
    hospitals.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));

    if (hospitals.isEmpty) {
      throw Exception(
        'No 24/7 hospitals found within 50 km. '
        'This could be due to a network issue or limited OpenStreetMap data in your area. '
        'Please check your internet connection and try again.',
      );
    }

    return hospitals;
  }
}

