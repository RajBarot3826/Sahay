// Sahay New Emergency Popup — Real Firestore SOS Data
// Shows real emergency details from citizen's SOS request.
// Accept/Decline writes to Firestore acceptedResponders array.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import '../constants/app_colors.dart';
import '../providers/responder_state.dart';
import '../services/firebase_dispatch_service.dart';
import 'incident_details_screen.dart';

class NewEmergencyPopup extends StatefulWidget {
  final Map<String, dynamic> emergencyData;
  
  const NewEmergencyPopup({super.key, required this.emergencyData});

  @override
  State<NewEmergencyPopup> createState() => _NewEmergencyPopupState();
}

class _NewEmergencyPopupState extends State<NewEmergencyPopup> {
  final AudioPlayer _alarmPlayer = AudioPlayer();
  bool _isAccepting = false;
  int _countdownSeconds = 30;

  Map<String, dynamic> get emergency => widget.emergencyData;

  @override
  void initState() {
    super.initState();
    _playAlarm();
    _startCountdown();
  }

  void _playAlarm() async {
    try {
      await _alarmPlayer.setReleaseMode(ReleaseMode.loop);
      await _alarmPlayer.play(AssetSource('sounds/sos_alarm.mp3'));
    } catch (e) {
      debugPrint('Alarm sound not available: $e');
    }
  }

  void _startCountdown() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() => _countdownSeconds--);
      if (_countdownSeconds <= 0) {
        _dismiss();
        return false;
      }
      return true;
    });
  }

  void _dismiss() {
    _alarmPlayer.stop();
    _alarmPlayer.dispose();
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _acceptEmergency() async {
    if (_isAccepting) return;
    setState(() => _isAccepting = true);
    _alarmPlayer.stop();

    final responderState = Provider.of<ResponderState>(context, listen: false);
    final firebaseService = Provider.of<FirebaseDispatchService>(context, listen: false);

    try {
      await firebaseService.acceptMission(
        emergencyId: emergency['id'],
        responderPhone: responderState.phone,
        responderName: responderState.driverName,
        vehicleType: responderState.vehicleType,
        responderLat: responderState.currentLat,
        responderLng: responderState.currentLng,
      );

      responderState.assignMission(emergency, emergency['id']);
      responderState.acceptEmergency();

      if (mounted) {
        Navigator.of(context).pop();
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => IncidentDetailsScreen(emergencyData: emergency),
        ));
      }
    } catch (e) {
      setState(() => _isAccepting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to accept: $e'), backgroundColor: AppColors.emergencyRed),
        );
      }
    }
  }

  String _getEmergencyType() {
    final type = emergency['type'] ?? 'unknown';
    switch (type) {
      case 'citizens': return '👤 Citizen Help Request';
      case 'ambulance': return '🚑 Ambulance Request';
      case 'both': return '🚨 Full Emergency (Citizens + Ambulance)';
      default: return '🚨 Emergency Alert';
    }
  }

  String _getCallerName() {
    return emergency['userName'] ?? 'Unknown Caller';
  }

  String _getCallerPhone() {
    return emergency['userPhone'] ?? '';
  }

  String _getRadiusInfo() {
    final radius = emergency['currentRadiusKm'] ?? 0;
    return '${radius} km search radius';
  }

  @override
  void dispose() {
    _alarmPlayer.stop();
    _alarmPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(color: AppColors.emergencyRed.withAlpha(80), blurRadius: 40, spreadRadius: 10),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Red emergency header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
              decoration: BoxDecoration(
                gradient: AppColors.emergencyGradient,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                children: [
                  // Countdown timer
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(40),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_countdownSeconds}s to respond',
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 56)
                      .animate(onPlay: (c) => c.repeat()).shake(duration: 600.ms, delay: 300.ms),
                  const SizedBox(height: 12),
                  const Text(
                    'INCOMING EMERGENCY',
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 1.5),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _getEmergencyType(),
                    style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),

            // Emergency details
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Caller info
                  _buildDetailRow(Icons.person_rounded, 'Caller', _getCallerName()),
                  if (_getCallerPhone().isNotEmpty)
                    _buildDetailRow(Icons.phone_rounded, 'Phone', _getCallerPhone()),
                  
                  // Blood group
                  if (emergency['bloodGroup'] != null && emergency['bloodGroup'].toString().isNotEmpty)
                    _buildDetailRow(Icons.bloodtype_rounded, 'Blood Group', emergency['bloodGroup']),
                  
                  // Radius
                  _buildDetailRow(Icons.radar_rounded, 'Search Area', _getRadiusInfo()),

                  const SizedBox(height: 24),

                  // Accept button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.successGreen,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                        elevation: 8,
                        shadowColor: AppColors.successGreen.withAlpha(100),
                      ),
                      onPressed: _isAccepting ? null : _acceptEmergency,
                      child: _isAccepting
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                          : const Text('ACCEPT & RESPOND', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.white, letterSpacing: 1)),
                    ),
                  ).animate().scale(delay: 400.ms, curve: Curves.easeOutBack),
                  
                  const SizedBox(height: 12),

                  // Decline button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey.withAlpha(80)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      ),
                      onPressed: _dismiss,
                      child: const Text('DECLINE', style: TextStyle(color: AppColors.textGrey, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ).animate().scale(curve: Curves.easeOutBack, duration: 500.ms),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryPurpleLight,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primaryPurple, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: AppColors.textGrey, fontSize: 11, fontWeight: FontWeight.w700)),
                Text(value, style: const TextStyle(color: AppColors.textDark, fontSize: 15, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
