// Screen 3: Home Dashboard — Real SOS Ecosystem
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers/auth_provider.dart';
import '../providers/emergency_provider.dart';
import '../providers/location_provider.dart';
import '../services/crash_sensor_service.dart';
import 'crash_detection_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  String? acceptedResponderName;
  int? responderEtaMins;
  late AnimationController _pulseController;
  
  // Crash Detection
  final CrashSensorService _crashSensor = CrashSensorService();
  StreamSubscription<bool>? _crashSubscription;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Fetch real GPS location + nearby hospitals immediately on app open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LocationProvider>(context, listen: false).initialize();
    });

    // Start crash detection monitoring
    _crashSensor.startMonitoring();
    _crashSubscription = _crashSensor.onCrashDetected.listen((crashed) {
      if (crashed && mounted) {
        // Navigate to crash detection screen with 15-second countdown
        _crashSensor.stopMonitoring();
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const CrashDetectionScreen()),
        ).then((_) {
          // Resume monitoring after returning from crash screen
          _crashSensor.startMonitoring();
        });
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _crashSubscription?.cancel();
    _crashSensor.dispose();
    super.dispose();
  }


  // ── SOS FLOW: Step 1 → 3-Second Countdown ──
  void triggerSos(BuildContext context) {
    final emergency = Provider.of<EmergencyProvider>(context, listen: false);
    emergency.startCountdown();
    _showCountdownOverlay(context);
  }

  void endSos(BuildContext context) {
    Provider.of<EmergencyProvider>(context, listen: false).cancelSOS();
  }

  // ── Full-screen 3-second countdown overlay ──
  void _showCountdownOverlay(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black87,
      pageBuilder: (ctx, anim1, anim2) {
        return Consumer<EmergencyProvider>(
          builder: (ctx, emergency, _) {
            // If countdown finished → close overlay and show options
            if (emergency.state == SosState.choosing) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.of(ctx).pop();
                _showSosOptionsPopup(context);
              });
            }

            // If cancelled → close overlay
            if (emergency.state == SosState.inactive) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (Navigator.of(ctx).canPop()) Navigator.of(ctx).pop();
              });
            }

            return PopScope(
              canPop: false,
              child: Scaffold(
                backgroundColor: Colors.transparent,
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Pulsing red circle with countdown
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.8, end: 1.2),
                        duration: const Duration(milliseconds: 800),
                        builder: (ctx, scale, child) {
                          return Transform.scale(
                            scale: scale,
                            child: Container(
                              width: 180,
                              height: 180,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.emergencyRed,
                                boxShadow: [
                                  BoxShadow(color: AppColors.emergencyRed.withAlpha(120), blurRadius: 40, spreadRadius: 20),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  '${emergency.countdownSeconds}',
                                  style: const TextStyle(color: Colors.white, fontSize: 72, fontWeight: FontWeight.w900),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'ACTIVATING SOS',
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 2),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Emergency alert will be sent...',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(height: 40),
                      // Cancel button
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white54, width: 2),
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        onPressed: () {
                          emergency.cancelCountdown();
                          Navigator.of(ctx).pop();
                        },
                        icon: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
                        label: const Text('CANCEL', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ── SOS FLOW: Step 2 → Options Popup ──
  void _showSosOptionsPopup(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final emergency = Provider.of<EmergencyProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 20),
              const Icon(Icons.sos_rounded, color: AppColors.emergencyRed, size: 48),
              const SizedBox(height: 12),
              const Text('Send Emergency Alert To', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: AppColors.textDark)),
              const SizedBox(height: 4),
              const Text('Choose who should receive your SOS', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              const SizedBox(height: 24),

              // Option 1: Nearest Citizens
              _buildSosOption(
                icon: Icons.people_rounded,
                color: AppColors.brandPurple,
                title: 'Alert Nearest Citizens',
                subtitle: 'Sahay users within 1-80 km will be notified',
                onTap: () {
                  Navigator.pop(ctx);
                  emergency.triggerSOS('citizens', userName: auth.userName, userPhone: auth.userPhone, bloodGroup: auth.bloodGroup);
                  Navigator.pushNamed(context, '/alert_confirmation');
                },
              ),
              const SizedBox(height: 12),

              // Option 2: Ambulance (108)
              _buildSosOption(
                icon: Icons.local_hospital_rounded,
                color: AppColors.emergencyRed,
                title: 'Alert Ambulance (108)',
                subtitle: 'Nearest ambulance & hospital will be alerted',
                onTap: () {
                  Navigator.pop(ctx);
                  emergency.triggerSOS('ambulance', userName: auth.userName, userPhone: auth.userPhone, bloodGroup: auth.bloodGroup);
                  Navigator.pushNamed(context, '/alert_confirmation');
                },
              ),
              const SizedBox(height: 12),

              // Option 3: Both
              _buildSosOption(
                icon: Icons.emergency_rounded,
                color: Colors.deepOrange,
                title: 'Alert BOTH (Citizens + Ambulance)',
                subtitle: 'Maximum help — everyone nearby will be alerted',
                onTap: () {
                  Navigator.pop(ctx);
                  emergency.triggerSOS('both', userName: auth.userName, userPhone: auth.userPhone, bloodGroup: auth.bloodGroup);
                  Navigator.pushNamed(context, '/alert_confirmation');
                },
                isPrimary: true,
              ),
              const SizedBox(height: 16),

              // Cancel
              TextButton(
                onPressed: () {
                  emergency.cancelCountdown();
                  Navigator.pop(ctx);
                },
                child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold, fontSize: 15)),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSosOption({required IconData icon, required Color color, required String title, required String subtitle, required VoidCallback onTap, bool isPrimary = false}) {
    return Material(
      color: isPrimary ? color.withAlpha(15) : AppColors.bgLight,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isPrimary ? color.withAlpha(60) : Colors.grey.withAlpha(30), width: isPrimary ? 2 : 1),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: color.withAlpha(20), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: isPrimary ? color : AppColors.textDark)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11.5, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, color: color, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    
    final auth = Provider.of<AuthProvider>(context);
    final emergency = Provider.of<EmergencyProvider>(context);
    
    final bool isSosActive = emergency.isEmergencyActive;
    String displayName = auth.userName.isNotEmpty ? auth.userName : (auth.userPhone.isNotEmpty ? auth.userPhone : 'Citizen Hero');

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      drawer: Drawer(
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              UserAccountsDrawerHeader(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                currentAccountPicture: const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person_rounded, size: 40, color: AppColors.brandPurple),
                ),
                accountName: Text(displayName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                accountEmail: Text(
                  '${auth.userPhone.isNotEmpty ? auth.userPhone : "+91 98765 43210"} ${auth.bloodGroup.isNotEmpty ? "• Blood: ${auth.bloodGroup}" : ""}',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.person_rounded, color: AppColors.brandPurple),
                title: const Text('My Profile', style: TextStyle(fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/user_profile');
                },
              ),
              ListTile(
                leading: const Icon(Icons.family_restroom_rounded, color: AppColors.brandPurple),
                title: const Text('Family SOS Network', style: TextStyle(fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/family_sos');
                },
              ),
              ListTile(
                leading: const Icon(Icons.contact_phone_rounded, color: AppColors.brandPurple),
                title: const Text('Emergency Contacts', style: TextStyle(fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/emergency_contacts');
                },
              ),
              ListTile(
                leading: const Icon(Icons.gavel_rounded, color: AppColors.brandPurple),
                title: const Text('Good Samaritan Protection', style: TextStyle(fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/good_samaritan_protection');
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings_rounded, color: AppColors.brandPurple),
                title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/settings');
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout_rounded, color: AppColors.emergencyRed),
                title: const Text('Logout', style: TextStyle(color: AppColors.emergencyRed, fontWeight: FontWeight.bold)),
                onTap: () async {
                  Navigator.pop(context);
                  await auth.logout();
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(context, '/registration', (route) => false);
                  }
                },
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (scaffoldContext) => Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: AppColors.softShadow),
            child: IconButton(
              icon: const Icon(Icons.menu_rounded, color: AppColors.textDark, size: 20),
              onPressed: () => Scaffold.of(scaffoldContext).openDrawer(),
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Welcome back,', style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
            Text(displayName, style: const TextStyle(color: AppColors.textDark, fontSize: 20, fontWeight: FontWeight.w900), overflow: TextOverflow.ellipsis),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: AppColors.softShadow),
            child: Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_none_rounded, color: AppColors.textDark, size: 22),
                  onPressed: () => Navigator.pushNamed(context, '/notifications'),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: AppColors.emergencyRed, shape: BoxShape.circle),
                    child: const Text('2', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Red Hero Emergency SOS Card (Matching Image 1 Screen 3)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: AppColors.emergencyGradient,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [BoxShadow(color: AppColors.emergencyRed.withAlpha(80), blurRadius: 20, spreadRadius: 2, offset: const Offset(0, 10))],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Emergency?', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5)),
                          SizedBox(height: 6),
                          Text('Tap SOS to alert 108\nand nearest responders', style: TextStyle(color: Colors.white, fontSize: 13, height: 1.4, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withAlpha((_pulseController.value * 100).toInt()),
                                blurRadius: 20 * _pulseController.value,
                                spreadRadius: 10 * _pulseController.value,
                              )
                            ]
                          ),
                          child: child,
                        );
                      },
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.emergencyRed,
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(32),
                          elevation: 10,
                          shadowColor: Colors.black45,
                        ),
                        onPressed: () => triggerSos(context),
                        child: const Text('SOS', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 1)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Live Accepted Responder Card
              if (acceptedResponderName != null) ...[
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.successGreen.withAlpha(50), width: 1.5),
                    boxShadow: AppColors.softShadow,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => Navigator.pushNamed(context, '/live_tracking'),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: const BoxDecoration(color: AppColors.successGreen, shape: BoxShape.circle),
                              child: const Icon(Icons.check_rounded, color: Colors.white, size: 24),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('RESPONDER EN ROUTE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: AppColors.successGreen, letterSpacing: 0.5)),
                                  const SizedBox(height: 4),
                                  Text(acceptedResponderName!, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textDark), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 2),
                                  Text('ETA: $responderEtaMins Mins • 550m away', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                            const Icon(Icons.location_on_rounded, color: AppColors.infoBlue, size: 24),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],

              const Text('QUICK ACTIONS', style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              const SizedBox(height: 16),

              // 6 Quick Action Grid Cards (Matching Image 1 Screen 3)
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.95,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                children: [
                  _buildActionCard(Icons.camera_alt_rounded, 'AI Accident Scan', AppColors.brandPurple, () => Navigator.pushNamed(context, '/ai_scan')),
                  _buildActionCard(Icons.medical_services_rounded, 'First Aid Assistant', AppColors.emergencyRed, () => Navigator.pushNamed(context, '/guided_first_aid')),
                  _buildActionCard(Icons.map_rounded, 'Live Tracking', AppColors.successGreen, () => Navigator.pushNamed(context, '/live_tracking')),
                  _buildActionCard(Icons.people_rounded, 'Nearby Responders', AppColors.warningAmber, () => Navigator.pushNamed(context, '/nearby_responders')),
                  _buildActionCard(Icons.local_hospital_rounded, 'Hospitals Nearby', AppColors.infoBlue, () => Navigator.pushNamed(context, '/hospitals_nearby')),
                  _buildActionCard(Icons.shield_rounded, 'Good Samaritan Laws', Colors.cyan, () => Navigator.pushNamed(context, '/good_samaritan_protection')),
                ],
              ),
              const SizedBox(height: 32),

              // Your Impact Banner Card (Matching Image 1 Screen 3)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: AppColors.softShadow,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => Navigator.pushNamed(context, '/incident_history'),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: AppColors.warningAmber.withAlpha(20), shape: BoxShape.circle),
                            child: const Icon(Icons.emoji_events_rounded, color: AppColors.warningAmber, size: 24),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Your Impact', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.textDark)),
                                SizedBox(height: 4),
                                Text('Helped 2 people • 1250 Points', style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.brandPurple, size: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),

      // White Bottom Navigation Bar (Matching Image 1 Screen 3)
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 20, offset: const Offset(0, -5))],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home_rounded, 'Home'),
                _buildNavItem(1, Icons.notifications_rounded, 'Alerts', route: '/notifications'),
                _buildNavItem(2, Icons.school_rounded, 'Learn', route: '/learn_train'),
                _buildNavItem(3, Icons.show_chart_rounded, 'Activity', route: '/impact_dashboard'),
                _buildNavItem(4, Icons.person_rounded, 'Profile', route: '/user_profile'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, {String? route}) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedIndex = index);
        if (route != null) Navigator.pushNamed(context, route);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.brandPurpleLight : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? AppColors.brandPurple : AppColors.textSecondary, size: 24),
            const SizedBox(height: 4),
            Text(
              label, 
              style: TextStyle(
                color: isSelected ? AppColors.brandPurple : AppColors.textSecondary, 
                fontSize: 10, 
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600
              )
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(IconData icon, String label, Color color, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.softShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: color.withAlpha(25),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 2,
                    style: const TextStyle(
                      fontSize: 13.5, 
                      fontWeight: FontWeight.w900, 
                      color: AppColors.textDark, 
                      height: 1.15
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
