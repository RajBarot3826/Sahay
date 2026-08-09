// Sahay Responder Dashboard — Real-World Data
// Auto-listens for Firestore emergencies, uses real profile from registration.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers/responder_state.dart';
import '../services/firebase_dispatch_service.dart';
import 'new_emergency_popup.dart';
import 'history_screen.dart';
import 'responder_profile_screen.dart';
import 'hospital_selection_screen.dart';
import 'incident_details_screen.dart';
import 'notifications_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ResponderDashboard extends StatefulWidget {
  const ResponderDashboard({super.key});

  @override
  State<ResponderDashboard> createState() => _ResponderDashboardState();
}

class _ResponderDashboardState extends State<ResponderDashboard> {
  int _currentIndex = 0;
  StreamSubscription? _emergencySubscription;
  bool _isShowingPopup = false;

  @override
  void initState() {
    super.initState();
    // Start listening for emergencies when dashboard loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startListeningForEmergencies();
    });
  }

  void _startListeningForEmergencies() {
    final firebaseService = Provider.of<FirebaseDispatchService>(context, listen: false);
    final responderState = Provider.of<ResponderState>(context, listen: false);

    _emergencySubscription?.cancel();
    _emergencySubscription = firebaseService.listenForEmergencies().listen((emergencies) {
      if (!mounted || !responderState.isActive || _isShowingPopup) return;
      
      // Filter out emergencies this responder already accepted
      final pendingEmergencies = emergencies.where((e) {
        final accepted = (e['acceptedResponders'] as List<dynamic>?) ?? [];
        final alreadyAccepted = accepted.any((r) => r['uid'] == responderState.phone);
        return !alreadyAccepted && e['status'] == 'searching';
      }).toList();

      if (pendingEmergencies.isNotEmpty && !_isShowingPopup) {
        _showEmergencyPopup(pendingEmergencies.first);
      }
    });
  }

  void _showEmergencyPopup(Map<String, dynamic> emergency) {
    if (_isShowingPopup) return;
    _isShowingPopup = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => NewEmergencyPopup(emergencyData: emergency),
    ).then((_) {
      _isShowingPopup = false;
    });
  }

  @override
  void dispose() {
    _emergencySubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: Consumer<ResponderState>(
        builder: (context, state, child) {
          if (_currentIndex == 1) {
            return const Center(child: Text("Map Mode"));
          } else if (_currentIndex == 2) {
            return const HistoryScreen();
          } else if (_currentIndex == 3) {
            return const ResponderProfileScreen();
          }

          // Real profile data
          final displayName = state.driverName.isNotEmpty ? state.driverName : 'Responder';
          final ambulanceInfo = state.ambulanceNumber.isNotEmpty
              ? 'Ambulance ${state.ambulanceNumber}'
              : (state.vehicleType.isNotEmpty ? state.vehicleType : 'Not registered');

          return SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with real profile
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryPurpleLight,
                          boxShadow: AppColors.innerGlowPurple,
                        ),
                        child: CircleAvatar(
                          radius: 26,
                          backgroundColor: AppColors.primaryPurple,
                          child: Text(
                            displayName.isNotEmpty ? displayName[0].toUpperCase() : 'R',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 22),
                          ),
                        ),
                      ).animate().scale(curve: Curves.easeOutBack, duration: 600.ms),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Hello, $displayName', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.textDark, letterSpacing: -0.5)),
                            const SizedBox(height: 4),
                            Text(ambulanceInfo, style: const TextStyle(color: AppColors.textGrey, fontSize: 14, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ).animate().fade().slideX(begin: 0.1),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                          );
                        },
                        child: Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: AppColors.softShadow,
                              ),
                              child: const Icon(Icons.notifications_none_rounded, color: AppColors.textDark, size: 26),
                            ),
                            StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('responders')
                                  .doc(state.phone)
                                  .collection('notifications')
                                  .where('read', isEqualTo: false)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                                  return Positioned(
                                    top: 10, right: 10,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: AppColors.emergencyRed,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 2),
                                      ),
                                      child: Text(
                                        '${snapshot.data!.docs.length}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ],
                        ),
                      ).animate().scale(curve: Curves.easeOutBack, delay: 100.ms),
                    ],
                  ),
                  
                  const SizedBox(height: 36),
                  
                  // Active Status Card
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: AppColors.premiumCardShadow,
                      border: Border.all(color: state.isActive ? AppColors.successGreen.withAlpha(80) : Colors.transparent, width: 2),
                    ),
                    child: Row(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            if (state.isActive)
                              Container(
                                width: 60, height: 60,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.successGreen.withAlpha(100),
                                ),
                              ).animate(onPlay: (c) => c.repeat()).scale(begin: const Offset(1, 1), end: const Offset(2, 2), duration: 1500.ms).fade(begin: 1, end: 0, duration: 1500.ms),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: state.isActive ? AppColors.successGreenLight : AppColors.primaryPurpleLight,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                state.isActive ? Icons.wifi_tethering_rounded : Icons.wifi_off_rounded,
                                color: state.isActive ? AppColors.successGreen : AppColors.textGrey,
                                size: 28,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                state.isActive ? "You're Online" : "You're Offline",
                                style: TextStyle(
                                  fontWeight: FontWeight.w900, fontSize: 20,
                                  color: state.isActive ? AppColors.successGreen : AppColors.textDark,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                state.isActive ? "Listening for SOS alerts..." : "Go online to receive requests",
                                style: const TextStyle(color: AppColors.textGrey, fontSize: 14, fontWeight: FontWeight.w600, height: 1.4),
                              ),
                              if (state.isActive && state.hasLocation)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.gps_fixed_rounded, size: 12, color: AppColors.successGreen),
                                      const SizedBox(width: 4),
                                      Text(
                                        'GPS: ${state.currentLat.toStringAsFixed(4)}, ${state.currentLng.toStringAsFixed(4)}',
                                        style: const TextStyle(fontSize: 10, color: AppColors.successGreen, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Transform.scale(
                          scale: 1.2,
                          child: Switch(
                            value: state.isActive,
                            onChanged: (val) => state.toggleActiveStatus(),
                            activeColor: Colors.white,
                            activeTrackColor: AppColors.successGreen,
                            inactiveThumbColor: Colors.white,
                            inactiveTrackColor: AppColors.textGrey.withAlpha(80),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fade(delay: 200.ms, duration: 500.ms).slideY(begin: 0.1),

                  const SizedBox(height: 40),

                  // Mission Stats — real data
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Mission Stats', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textDark, letterSpacing: -0.5)),
                      Text('See All', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.primaryPurple)),
                    ],
                  ).animate().fade(delay: 300.ms),
                  
                  const SizedBox(height: 20),
                  
                  // Stats Row — real data from Firestore
                  Row(
                    children: [
                      Expanded(child: _buildStatCard('Missions', '${state.completedMissionsCount}', Icons.local_taxi_rounded, AppColors.primaryPurpleLight, AppColors.primaryPurple)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildStatCard('Lives Saved', '${state.livesSaved}', Icons.favorite_rounded, AppColors.emergencyRedBg, AppColors.emergencyRed)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildStatCard('Status', state.isActive ? 'ON' : 'OFF', Icons.wifi_tethering_rounded, const Color(0xFFE0F2FE), const Color(0xFF0284C7))),
                    ],
                  ).animate().fade(delay: 400.ms).slideX(begin: 0.1),

                  const SizedBox(height: 40),

                  // Quick Actions
                  const Text('Quick Actions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textDark, letterSpacing: -0.5))
                      .animate().fade(delay: 500.ms),
                      
                  const SizedBox(height: 20),

                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    childAspectRatio: 1.05,
                    children: [
                      _buildActionCard(
                        'Current\nMission',
                        Icons.warning_rounded,
                        AppColors.emergencyGradient,
                        Colors.white,
                        badge: state.currentMissionData != null ? '1' : null,
                        onTap: () {
                          if (state.currentMissionData != null) {
                            Navigator.push(context, MaterialPageRoute(
                              builder: (_) => IncidentDetailsScreen(emergencyData: state.currentMissionData!),
                            ));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('No active mission'), behavior: SnackBarBehavior.floating),
                            );
                          }
                        },
                      ),
                      _buildActionCard(
                        'AI Accident\nScan',
                        Icons.document_scanner_rounded,
                        const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                        Colors.white,
                        onTap: () => _showFeaturePopup(context, 'AI Accident Scan'),
                      ),
                      _buildActionCard(
                        'Live\nTracking',
                        Icons.satellite_alt_rounded,
                        const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF047857)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                        Colors.white,
                        onTap: () => _showFeaturePopup(context, 'Live Tracking System'),
                      ),
                      _buildActionCard(
                        'Nearby\nHospitals',
                        Icons.local_hospital_rounded,
                        const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFD97706)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                        Colors.white,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HospitalSelectionScreen())),
                      ),
                    ],
                  ).animate().fade(delay: 600.ms).slideY(begin: 0.1),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: AppColors.primaryPurple.withAlpha(15), blurRadius: 30, offset: const Offset(0, -10))],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primaryPurple,
          unselectedItemColor: AppColors.textGrey.withAlpha(120),
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(icon: Padding(padding: EdgeInsets.only(bottom: 6, top: 8), child: Icon(Icons.home_filled, size: 26)), label: 'Home'),
            BottomNavigationBarItem(icon: Padding(padding: EdgeInsets.only(bottom: 6, top: 8), child: Icon(Icons.map_rounded, size: 26)), label: 'Map'),
            BottomNavigationBarItem(icon: Padding(padding: EdgeInsets.only(bottom: 6, top: 8), child: Icon(Icons.history_rounded, size: 26)), label: 'History'),
            BottomNavigationBarItem(icon: Padding(padding: EdgeInsets.only(bottom: 6, top: 8), child: Icon(Icons.person_rounded, size: 26)), label: 'Profile'),
          ],
        ),
      ),
    );
  }

  void _showFeaturePopup(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: AppColors.premiumCardShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: AppColors.primaryPurpleLight, shape: BoxShape.circle),
                child: const Icon(Icons.auto_awesome_rounded, color: AppColors.primaryPurple, size: 48),
              ),
              const SizedBox(height: 24),
              Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.textDark)),
              const SizedBox(height: 12),
              const Text(
                'This feature activates automatically during a live mission.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textGrey, height: 1.4),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.bgColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('GOT IT', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.textDark, letterSpacing: 1.0)),
                ),
              ),
            ],
          ),
        ).animate().scale(curve: Curves.easeOutBack, duration: 400.ms),
      ),
    );
  }

  Widget _buildStatCard(String title, String count, IconData icon, Color bgColor, Color iconColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 26),
          ),
          const SizedBox(height: 16),
          Text(count, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 26, color: AppColors.textDark, letterSpacing: -1)),
          const SizedBox(height: 4),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textGrey, fontSize: 13, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  Widget _buildActionCard(String title, IconData icon, LinearGradient gradient, Color textColor, {VoidCallback? onTap, String? badge}) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [BoxShadow(color: gradient.colors.first.withAlpha(100), blurRadius: 20, offset: const Offset(0, 8))],
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white.withAlpha(60), shape: BoxShape.circle),
                  child: Icon(icon, color: Colors.white, size: 32),
                ),
                Text(title, style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontSize: 18, height: 1.2, letterSpacing: -0.5)),
              ],
            ),
          ),
          if (badge != null)
            Positioned(
              top: 8, right: 8,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: Text(badge, style: const TextStyle(color: AppColors.emergencyRed, fontWeight: FontWeight.w900, fontSize: 14)),
              ),
            ),
        ],
      ),
    );
  }
}
