// Flutter Model for Hospital Location Data (Google Maps Places API Integration)
class HospitalModel {
  final String id;
  final String name;
  final String type;
  final String address;
  final double latitude;
  final double longitude;
  final double distanceKm;
  final int etaMins;
  final double rating;
  final bool is24x7;
  final String emergencyPhone;
  final List<String> traumaFacilities;
  final bool cashlessSupported;

  HospitalModel({
    required this.id,
    required this.name,
    required this.type,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.distanceKm,
    required this.etaMins,
    required this.rating,
    required this.is24x7,
    required this.emergencyPhone,
    required this.traumaFacilities,
    required this.cashlessSupported,
  });

  factory HospitalModel.fromJson(Map<String, dynamic> json) {
    return HospitalModel(
      id: json['place_id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? 'Trauma Hospital',
      address: json['address'] ?? '',
      latitude: (json['location']['lat'] as num).toDouble(),
      longitude: (json['location']['lng'] as num).toDouble(),
      distanceKm: (json['distance_km'] as num).toDouble(),
      etaMins: json['eta_mins'] ?? 5,
      rating: (json['rating'] as num).toDouble(),
      is24x7: json['open_24_7'] ?? true,
      emergencyPhone: json['emergency_phone'] ?? '',
      traumaFacilities: List<String>.from(json['trauma_facilities'] ?? []),
      cashlessSupported: json['cashless_scheme_supported'] ?? true,
    );
  }
}
