// Flutter Screen 6: Alert Sent Confirmation — Real-Time SOS Dispatch Status
// Shows live expanding radius visualization, real-time responder acceptances,
// and Firestore-backed dispatch status.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers/emergency_provider.dart';
import '../services/sos_radius_service.dart';

class AlertConfirmationScreen extends StatefulWidget {
  const AlertConfirmationScreen({Key? key}) : super(key: key);

  @override
  State<AlertConfirmationScreen> createState() => _AlertConfirmationScreenState();
}

class _AlertConfirmationScreenState extends State<AlertConfirmationScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    return Consumer<EmergencyProvider>(
      builder: (context, emergency, _) {
        final bool isSearching = emergency.state == SosState.searching;
        final bool isAccepted = emergency.state == SosState.accepted || emergency.state == SosState.tracking;

        return Scaffold(
          backgroundColor: AppColors.bgLight,
          appBar: AppBar(
            title: Text(
              isAccepted ? 'RESPONDERS FOUND' : 'SEARCHING FOR HELP',
              style: const TextStyle(color: AppColors.textDark, fontSize: 12, letterSpacing: 1.5, fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            automaticallyImplyLeading: false,
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                children: [
                  const SizedBox(height: 10),

                  // Animated Radar / Success Badge
                  if (isAccepted) ...[
                    // Success badge
                    Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: AppColors.successGreen,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: AppColors.successGreen.withAlpha(100), blurRadius: 30, spreadRadius: 8),
                        ],
                      ),
                      child: const Icon(Icons.check_rounded, size: 64, color: Colors.white),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '${emergency.acceptedCount} Responders Accepted!',
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: AppColors.textDark),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Help is on the way. Stay calm.',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                    ),
                  ] else ...[
                    // Searching radar animation
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (ctx, child) {
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            // Outer expanding ring
                            Container(
                              width: 160 + (60 * _pulseController.value),
                              height: 160 + (60 * _pulseController.value),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.emergencyRed.withAlpha((20 * (1 - _pulseController.value)).toInt()),
                                border: Border.all(
                                  color: AppColors.emergencyRed.withAlpha((80 * (1 - _pulseController.value)).toInt()),
                                  width: 2,
                                ),
                              ),
                            ),
                            // Inner circle with radius info
                            Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.emergencyRed,
                                boxShadow: [
                                  BoxShadow(color: AppColors.emergencyRed.withAlpha(80), blurRadius: 20, spreadRadius: 5),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    emergency.currentRadiusKm.toStringAsFixed(0),
                                    style: const TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.w900),
                                  ),
                                  const Text(
                                    'KM RADIUS',
                                    style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Searching for nearby responders...',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: AppColors.textDark),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Radius will expand automatically every 15 seconds\nif ${SosRadiusService.minAcceptors} responders haven\'t accepted yet.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.4),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Radius Expansion Progress
                  _buildRadiusProgress(emergency),
                  const SizedBox(height: 20),

                  // Live Dispatch Status
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: AppColors.softShadow,
                      ),
                      child: ListView(
                        padding: const EdgeInsets.all(20),
                        physics: const BouncingScrollPhysics(),
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.sensors_rounded, color: AppColors.brandPurple, size: 18),
                              const SizedBox(width: 8),
                              const Text('Live Dispatch Status', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.brandPurple)),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: (isSearching ? AppColors.emergencyRed : AppColors.successGreen).withAlpha(20),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    if (isSearching)
                                      const SizedBox(width: 10, height: 10, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.emergencyRed)),
                                    if (isSearching) const SizedBox(width: 4),
                                    Text(
                                      isSearching ? 'Searching' : 'Found',
                                      style: TextStyle(color: isSearching ? AppColors.emergencyRed : AppColors.successGreen, fontSize: 10, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Acceptance counter
                          _buildStatusRow(
                            Icons.people_rounded,
                            'Responders Accepted',
                            '${emergency.acceptedCount} / ${SosRadiusService.minAcceptors} needed',
                            emergency.acceptedCount >= SosRadiusService.minAcceptors ? AppColors.successGreen : AppColors.warningAmber,
                            isDone: emergency.acceptedCount >= SosRadiusService.minAcceptors,
                          ),

                          // SOS Type info
                          _buildStatusRow(
                            emergency.sosType == 'ambulance' ? Icons.local_hospital_rounded : Icons.people_rounded,
                            'Alert Type',
                            emergency.sosType == 'citizens' ? 'Nearby Citizens' : (emergency.sosType == 'ambulance' ? '108 Ambulance' : 'Citizens + Ambulance'),
                            AppColors.brandPurple,
                            isDone: true,
                          ),

                          // Radius info
                          _buildStatusRow(
                            Icons.radar_rounded,
                            'Search Radius',
                            '${emergency.currentRadiusKm.toStringAsFixed(0)} km',
                            AppColors.infoBlue,
                            isDone: false,
                            isSearching: isSearching,
                          ),

                          // Accepted responder cards
                          if (emergency.acceptedResponders.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            const Text('ACCEPTED RESPONDERS', style: TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.bold, letterSpacing: 1)),
                            const SizedBox(height: 8),
                            ...emergency.acceptedResponders.map((r) => _buildResponderCard(r)),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Action buttons
                  if (isAccepted)
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.successGreen,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                          elevation: 6,
                          shadowColor: AppColors.successGreen.withAlpha(100),
                        ),
                        onPressed: () => Navigator.pushNamed(context, '/live_tracking'),
                        child: const Text('Track Live Location', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Colors.white)),
                      ),
                    ),

                  if (isSearching)
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey.withAlpha(80)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        ),
                        onPressed: () async {
                          await emergency.cancelSOS();
                          if (context.mounted) Navigator.pop(context);
                        },
                        child: const Text('Cancel SOS', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRadiusProgress(EmergencyProvider emergency) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(SosRadiusService.radiusLevels.length, (i) {
        final bool isActive = i <= emergency.currentRadiusIndex;
        final bool isCurrent = i == emergency.currentRadiusIndex;
        return Row(
          children: [
            Container(
              width: isCurrent ? 36 : 28,
              height: isCurrent ? 36 : 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive ? AppColors.emergencyRed : Colors.grey.withAlpha(40),
                border: isCurrent ? Border.all(color: AppColors.emergencyRed, width: 3) : null,
                boxShadow: isCurrent ? [BoxShadow(color: AppColors.emergencyRed.withAlpha(60), blurRadius: 8)] : null,
              ),
              child: Center(
                child: Text(
                  '${SosRadiusService.radiusLevels[i].toInt()}',
                  style: TextStyle(
                    color: isActive ? Colors.white : AppColors.textSecondary,
                    fontSize: isCurrent ? 11 : 9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            if (i < SosRadiusService.radiusLevels.length - 1)
              Container(
                width: 12, height: 2,
                color: isActive ? AppColors.emergencyRed : Colors.grey.withAlpha(40),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildStatusRow(IconData icon, String name, String status, Color iconColor, {bool isDone = false, bool isSearching = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: iconColor.withAlpha(20), shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textDark)),
                const SizedBox(height: 2),
                Row(
                  children: [
                    if (isSearching)
                      SizedBox(width: 10, height: 10, child: CircularProgressIndicator(strokeWidth: 2, color: iconColor))
                    else
                      Icon(isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded, size: 12, color: iconColor),
                    const SizedBox(width: 6),
                    Expanded(child: Text(status, style: TextStyle(color: iconColor, fontSize: 12, fontWeight: FontWeight.w600))),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponderCard(Map<String, dynamic> responder) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.successGreen.withAlpha(10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.successGreen.withAlpha(40)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.successGreen.withAlpha(20), shape: BoxShape.circle),
            child: const Icon(Icons.person_rounded, color: AppColors.successGreen, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  responder['name'] ?? 'Responder',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textDark),
                ),
                Text(
                  '${responder['distanceKm'] ?? '?'} km away • ETA ~${responder['etaMins'] ?? '?'} mins',
                  style: const TextStyle(color: AppColors.successGreen, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const Icon(Icons.check_circle_rounded, color: AppColors.successGreen, size: 20),
        ],
      ),
    );
  }
}
