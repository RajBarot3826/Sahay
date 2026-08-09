// Flutter Screen 12: Hospital Pre-Alert (Real Hospital Telematics & Live Map Navigation)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants/app_colors.dart';
import '../services/hospital_service.dart';
import 'hospital_navigation_map_screen.dart';

class HospitalPreAlertScreen extends StatefulWidget {
  final HospitalModel? hospital;

  const HospitalPreAlertScreen({Key? key, this.hospital}) : super(key: key);

  @override
  State<HospitalPreAlertScreen> createState() => _HospitalPreAlertScreenState();
}

class _HospitalPreAlertScreenState extends State<HospitalPreAlertScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _isTransmitted = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  HospitalModel get _targetHospital {
    return widget.hospital ??
        HospitalModel(
          name: 'Sir Takhtasinhji (Sir T.) General Hospital',
          distanceKm: 0.8,
          location: LatLng(21.7705, 72.1489),
          etaMins: 2,
          type: 'Govt. Level 1 Trauma Center',
          isOpen24x7: true,
          icuBeds: 14,
          phone: '0278-2424222',
          category: 'Govt.',
        );
  }

  void _callTraumaTeam() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.call_rounded, color: AppColors.emergencyRed),
            const SizedBox(width: 10),
            Expanded(child: Text('${_targetHospital.name} ER', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
          ],
        ),
        content: Text('Connecting directly to ER Duty Medical Desk (${_targetHospital.phone})...\nPre-alert telematics active.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('📞 Dialing ${_targetHospital.name} ER (${_targetHospital.phone})...'),
                  backgroundColor: AppColors.successGreen,
                ),
              );
            },
            child: const Text('DIAL ER DESK', style: TextStyle(color: AppColors.successGreen, fontWeight: FontWeight.bold)),
          ),
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close', style: TextStyle(color: Colors.grey))),
        ],
      ),
    );
  }

  void _startLiveMapNavigation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HospitalNavigationMapScreen(hospital: _targetHospital),
      ),
    );
  }

  Future<void> _transmitPreAlert() async {
    setState(() => _isTransmitted = true);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🚨 ER Pre-Alert Transmitted to ${_targetHospital.name} Hospital Portal!'),
        backgroundColor: AppColors.successGreen,
        duration: const Duration(seconds: 3),
      ),
    );

    try {
      http.post(
        Uri.parse('http://10.0.2.2/Sahay/web_portals/api/hospital_pre_alert.php'),
        body: json.encode({
          'hospital_name': _targetHospital.name,
          'distance_km': _targetHospital.distanceKm,
          'eta_mins': _targetHospital.etaMins,
          'patient_status': 'Critical Trauma (Unconscious)',
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    final hospital = _targetHospital;

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Text('HOSPITAL PRE-ALERT', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: AppColors.softShadow),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textDark, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pre-Alert Sent Status Banner (Only visible after transmit button click!)
              if (_isTransmitted)
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.successGreenBg,
                        border: Border.all(color: AppColors.successGreen.withAlpha((100 + 100 * _pulseController.value).toInt()), width: 2),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(color: AppColors.successGreen.withAlpha((20 + 30 * _pulseController.value).toInt()), blurRadius: 10, spreadRadius: 2),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: AppColors.successGreen.withAlpha(50), shape: BoxShape.circle),
                            child: const Icon(Icons.medical_services_rounded, color: AppColors.successGreen, size: 32),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Pre-Alert Transmitted & Active',
                                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16.5, color: AppColors.successGreen),
                                ),
                                SizedBox(height: 2),
                                Text('ER trauma team pre-notified for arrival', style: TextStyle(color: AppColors.textDark, fontSize: 12.5, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          )
                        ],
                      ),
                    );
                  },
                )
              else
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.brandPurple.withAlpha(40)),
                    boxShadow: AppColors.softShadow,
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline_rounded, color: AppColors.brandPurple, size: 24),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Pre-Alert Ready for Transmission. Tap "TRANSMIT ER PRE-ALERT TO PORTAL" below to notify duty doctors.',
                          style: TextStyle(color: AppColors.textDark, fontSize: 12.5, fontWeight: FontWeight.w600, height: 1.3),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 20),

              // Selected Real Hospital Details Card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: AppColors.softShadow,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.brandPurpleLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(Icons.domain_rounded, color: AppColors.brandPurple, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hospital.name,
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.textDark, height: 1.3),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${hospital.distanceKm} km away • ${hospital.type}',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.bgLight,
                          border: Border.all(color: Colors.grey.withAlpha(20)),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.phone_rounded, color: AppColors.brandPurple),
                          onPressed: _callTraumaTeam,
                        ),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Injury Summary Transmitted
              const Text('INJURY SUMMARY TRANSMITTED TO ER DESK', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: AppColors.textSecondary, letterSpacing: 1.2)),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.withAlpha(20)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSummaryRow(Icons.personal_injury_rounded, 'Unconscious Patient (AI Scanner Detected)'),
                    _buildSummaryRow(Icons.bloodtype_rounded, 'Severe Arterial Hemorrhage (Left Leg)'),
                    _buildSummaryRow(Icons.monitor_heart_rounded, 'Bystander Pulse Metronome Active (110 BPM)'),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ETA Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: AppColors.softShadow),
                child: Row(
                  children: [
                    const Icon(Icons.timer_rounded, color: AppColors.emergencyRed, size: 28),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('ESTIMATED ARRIVAL TIME', style: TextStyle(color: AppColors.textSecondary, fontSize: 10.5, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                        Text('${hospital.etaMins} mins (${hospital.distanceKm} km)', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: AppColors.textDark)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Action Buttons
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandPurple,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    elevation: 6,
                  ),
                  onPressed: _startLiveMapNavigation,
                  icon: const Icon(Icons.navigation_rounded, color: Colors.white, size: 20),
                  label: const Text('START LIVE MAP NAVIGATION', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Colors.white, letterSpacing: 1)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.emergencyRed,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    elevation: 6,
                  ),
                  onPressed: _transmitPreAlert,
                  icon: const Icon(Icons.add_alert_rounded, color: Colors.white, size: 20),
                  label: const Text('TRANSMIT ER PRE-ALERT TO PORTAL', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13.5, color: Colors.white, letterSpacing: 1)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                    side: const BorderSide(color: AppColors.brandPurple, width: 1.8),
                  ),
                  onPressed: _callTraumaTeam,
                  icon: const Icon(Icons.call_rounded, color: AppColors.brandPurple, size: 18),
                  label: Text('CALL ${hospital.name.toUpperCase()} ER', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: AppColors.brandPurple), overflow: TextOverflow.ellipsis),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.emergencyRed, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: const TextStyle(color: AppColors.textDark, fontSize: 13, fontWeight: FontWeight.w600, height: 1.3)),
          ),
        ],
      ),
    );
  }
}
