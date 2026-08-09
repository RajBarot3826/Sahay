// Flutter Model for Emergency Incident Payload
class IncidentModel {
  final String incidentId;
  final String status; // 'BROADCASTING', 'ACCEPTED', 'EN_ROUTE', 'COMPLETED'
  final String victimName;
  final String victimPhone;
  final double latitude;
  final double longitude;
  final String locationAddress;
  final String severity; // 'HIGH_SEVERITY', 'MEDIUM', 'LOW'
  final List<String> detectedInjuries;
  final String? acceptedResponderName;
  final String? acceptedResponderPhone;
  final int? responderEtaMins;
  final double? responderDistanceMeters;
  final DateTime timestamp;

  IncidentModel({
    required this.incidentId,
    required this.status,
    required this.victimName,
    required this.victimPhone,
    required this.latitude,
    required this.longitude,
    required this.locationAddress,
    required this.severity,
    required this.detectedInjuries,
    this.acceptedResponderName,
    this.acceptedResponderPhone,
    this.responderEtaMins,
    this.responderDistanceMeters,
    required this.timestamp,
  });

  factory IncidentModel.fromJson(Map<String, dynamic> json) {
    return IncidentModel(
      incidentId: json['incident_id'] ?? '',
      status: json['status'] ?? 'BROADCASTING',
      victimName: json['victim_name'] ?? 'Raj Barot',
      victimPhone: json['victim_phone'] ?? '+91 98765 43210',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      locationAddress: json['location_address'] ?? 'NH-8E Km 14, Chitra Crossing, Bhavnagar',
      severity: json['severity'] ?? 'HIGH_SEVERITY',
      detectedInjuries: List<String>.from(json['detected_injuries'] ?? []),
      acceptedResponderName: json['accepted_responder_name'],
      acceptedResponderPhone: json['accepted_responder_phone'],
      responderEtaMins: json['responder_eta_mins'],
      responderDistanceMeters: (json['responder_distance_meters'] as num?)?.toDouble(),
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
    );
  }
}
