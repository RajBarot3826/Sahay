import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_colors.dart';
import 'package:flutter/services.dart';
import 'edar_report_screen.dart';
import 'pcr_calls_queue_screen.dart';
import 'scanners_hub_screen.dart';
import 'police_profile_screen.dart';

class PoliceDashboard extends StatefulWidget {
  const PoliceDashboard({super.key});

  @override
  State<PoliceDashboard> createState() => _PoliceDashboardState();
}

class _PoliceDashboardState extends State<PoliceDashboard> {
  int _currentIndex = 0;
  final bool _isPatrolling = true;
  
  @override
  Widget build(BuildContext context) {
    final bool hasActiveAlert = _isPatrolling;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.bgColor,
        body: IndexedStack(
          index: _currentIndex,
          children: [
            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Premium App Bar Header
                    Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primaryBlueLight,
                            boxShadow: AppColors.innerGlowBlue,
                            border: Border.all(color: AppColors.primaryBlue, width: 2),
                          ),
                          child: const CircleAvatar(
                            radius: 26,
                            backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=52'),
                          ),
                        ).animate().scale(curve: Curves.easeOutBack, duration: 600.ms),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Inspector R. Sharma', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.white, letterSpacing: -0.5)),
                              SizedBox(height: 4),
                              Text('Unit PCR-44 (Sector 9)', style: TextStyle(color: AppColors.techCyan, fontSize: 14, fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ).animate().fade().slideX(begin: 0.1),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.navyDark,
                            shape: BoxShape.circle,
                            boxShadow: AppColors.softShadow,
                            border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.3)),
                          ),
                          child: const Icon(Icons.menu_rounded, color: Colors.white, size: 26),
                        ).animate().scale(curve: Curves.easeOutBack, delay: 100.ms),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),

                  // Massive White Card containing Map
                  Container(
                    width: double.infinity,
                    height: 500,
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: AppColors.premiumCardShadow,
                      border: Border.all(color: AppColors.primaryBlueLight.withValues(alpha: 0.5), width: 4),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(36),
                      child: Stack(
                        children: [
                            if (hasActiveAlert)
                              _buildActiveAlertMap()
                          else
                            _buildPatrolMap(),
                            
                          // Overlay UI on Map
                          Positioned(
                            top: 24,
                            left: 24,
                            right: 24,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                              decoration: BoxDecoration(
                                color: hasActiveAlert ? AppColors.emergencyRed : AppColors.navyDarker.withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: hasActiveAlert ? AppColors.glowRed : AppColors.mapFloatingShadow,
                                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                              ),
                              child: Row(
                                children: [
                                  Icon(hasActiveAlert ? Icons.warning_rounded : Icons.radar_rounded, color: Colors.white, size: 28),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          hasActiveAlert ? 'EMERGENCY DISPATCH' : 'SECTOR PATROL ACTIVE',
                                          style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 16, letterSpacing: 1.0),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          hasActiveAlert ? 'Highway Collision Reported' : 'Monitoring assigned zones',
                                          style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13, fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ).animate(onPlay: (c) => hasActiveAlert ? c.repeat(reverse: true) : null)
                             .tint(color: hasActiveAlert ? AppColors.primaryBlue : Colors.transparent, duration: 800.ms),
                          ),
                          
                          // Action Button at bottom of map
                          if (hasActiveAlert)
                            Positioned(
                              bottom: 24,
                              left: 24,
                              right: 24,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  gradient: AppColors.policeGradient,
                                  boxShadow: AppColors.innerGlowBlue,
                                ),
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (_) => const EdarReportScreen()));
                                  },
                                  icon: const Icon(Icons.receipt_long_rounded, color: Colors.white),
                                  label: const Text('INITIATE eDAR PROTOCOL', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.0)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    padding: const EdgeInsets.symmetric(vertical: 20),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  ),
                                ),
                              ).animate().slideY(begin: 1.0, curve: Curves.easeOutBack),
                            ),
                        ],
                      ),
                    ),
                  ).animate().fade(delay: 200.ms, duration: 600.ms).slideY(begin: 0.1),

                  const SizedBox(height: 40),

                  // Stats Row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      children: [
                        Expanded(child: _buildStatCard('Active Calls', '2', Icons.call_rounded, AppColors.emergencyRedBg, AppColors.emergencyRed)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildStatCard('Units Online', '14', Icons.local_police_rounded, AppColors.primaryBlueLight, AppColors.primaryBlue)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildStatCard('Clearance', '98%', Icons.verified_rounded, AppColors.successGreenLight, AppColors.successGreen)),
                      ],
                    ).animate().fade(delay: 400.ms).slideX(begin: 0.1),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          const ScannersHubScreen(),

            const PcrCallsQueueScreen(),
            const PoliceProfileScreen(),
          ],
        ),
        bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.navyDark,
          border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.1), width: 1)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 30, offset: const Offset(0, -10))],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.navyDark,
          selectedItemColor: AppColors.techCyan,
          unselectedItemColor: AppColors.textGrey,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(icon: Padding(padding: EdgeInsets.only(bottom: 6, top: 8), child: Icon(Icons.dashboard_rounded, size: 26)), label: 'Command'),
            BottomNavigationBarItem(icon: Padding(padding: EdgeInsets.only(bottom: 6, top: 8), child: Icon(Icons.document_scanner_rounded, size: 26)), label: 'Scanners'),
            BottomNavigationBarItem(icon: Padding(padding: EdgeInsets.only(bottom: 6, top: 8), child: Icon(Icons.list_alt_rounded, size: 26)), label: 'Queue'),
            BottomNavigationBarItem(icon: Padding(padding: EdgeInsets.only(bottom: 6, top: 8), child: Icon(Icons.admin_panel_settings_rounded, size: 26)), label: 'Profile'),
          ],
        ),
      ),
    ));
  }
  
  Widget _buildStatCard(String title, String count, IconData icon, Color bgColor, Color iconColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.navyDark,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.2)),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: bgColor.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 26),
          ),
          const SizedBox(height: 16),
          Text(count, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 26, color: Colors.white, letterSpacing: -1)),
          const SizedBox(height: 4),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textGrey, fontSize: 13, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  Widget _buildPatrolMap() {
    return FlutterMap(
      options: MapOptions(
        initialCenter: const LatLng(21.7645, 72.1519),
        initialZoom: 15.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
          userAgentPackageName: 'com.example.sahay_police_app',
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: const LatLng(21.7645, 72.1519),
              width: 80,
              height: 80,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryBlue.withValues(alpha: 0.3),
                    ),
                  ).animate(onPlay: (controller) => controller.repeat()).scale(begin: const Offset(1, 1), end: const Offset(2.5, 2.5), duration: 2000.ms).fade(begin: 1, end: 0, duration: 2000.ms),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: AppColors.innerGlowBlue,
                    ),
                    child: const Icon(Icons.directions_car_rounded, color: Colors.white, size: 24),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildActiveAlertMap() {
    final double lat = 21.7645;
    final double lng = 72.1519;
    
    return FlutterMap(
      options: MapOptions(
        initialCenter: LatLng(lat, lng),
        initialZoom: 16.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
          userAgentPackageName: 'com.example.sahay_police_app',
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: LatLng(lat, lng),
              width: 100,
              height: 100,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.emergencyRed.withValues(alpha: 0.3),
                    ),
                  ).animate(onPlay: (controller) => controller.repeat()).scale(begin: const Offset(1, 1), end: const Offset(2, 2), duration: 1000.ms).fade(begin: 1, end: 0, duration: 1000.ms),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.emergencyRed,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: AppColors.glowRed,
                    ),
                    child: const Icon(Icons.warning_rounded, color: Colors.white, size: 32),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
