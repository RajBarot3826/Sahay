// Sahay Nearby Responder Champion Model
class ResponderModel {
  final String id;
  final String name;
  final String role; // 'Dhaba Champion', 'Auto Champion', 'CPR Volunteer'
  final String phone;
  final double distanceKm;
  final int etaMins;
  final bool isAvailable;
  final String locationAddress;

  ResponderModel({
    required this.id,
    required this.name,
    required this.role,
    required this.phone,
    required this.distanceKm,
    required this.etaMins,
    required this.isAvailable,
    required this.locationAddress,
  });
}
