// Sahay Google Maps Hospital Model
class HospitalModel {
  final String placeId;
  final String name;
  final String category; // 'Govt', 'Trauma', 'Private'
  final String address;
  final double latitude;
  final double longitude;
  final double distanceKm;
  final int etaMins;
  final double rating;
  final bool open24x7;
  final String emergencyPhone;
  final List<String> traumaFacilities;
  final bool cashlessSchemeSupported;

  HospitalModel({
    required this.placeId,
    required this.name,
    required this.category,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.distanceKm,
    required this.etaMins,
    required this.rating,
    required this.open24x7,
    required this.emergencyPhone,
    required this.traumaFacilities,
    required this.cashlessSchemeSupported,
  });
}
