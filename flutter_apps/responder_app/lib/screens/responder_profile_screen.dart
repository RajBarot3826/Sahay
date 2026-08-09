import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers/responder_state.dart';
import 'settings_screen.dart';

class ResponderProfileScreen extends StatelessWidget {
  const ResponderProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SafeArea(
        child: Consumer<ResponderState>(
          builder: (context, state, child) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('My Profile', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.textDark, letterSpacing: -0.5)),
                        GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: AppColors.softShadow),
                            child: const Icon(Icons.settings_rounded, color: AppColors.textDark, size: 24),
                          ),
                        ).animate().scale(curve: Curves.easeOutBack, duration: 400.ms),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Profile Card
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: AppColors.premiumCardShadow,
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.primaryPurple.withOpacity(0.05),
                            shape: BoxShape.circle,
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryPurpleLight,
                              shape: BoxShape.circle,
                              boxShadow: AppColors.innerGlowPurple,
                            ),
                            child: const CircleAvatar(
                              radius: 50,
                              backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11'),
                            ),
                          ),
                        ).animate().scale(delay: 50.ms, curve: Curves.easeOutBack, duration: 600.ms),
                        
                        const SizedBox(height: 24),
                        
                        Text(state.driverName.isNotEmpty ? state.driverName : 'Unknown', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.textDark, letterSpacing: -0.5)),
                        const SizedBox(height: 4),
                        Text('${state.vehicleType.isNotEmpty ? state.vehicleType : 'EMT'} • ${state.driverLicense.isNotEmpty ? state.driverLicense : 'No License'}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textGrey)),
                        
                        const SizedBox(height: 32),
                        
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStat('Rating', '4.9', Icons.star_rounded, AppColors.warningAmber),
                            Container(width: 1.5, height: 40, color: AppColors.textGrey.withOpacity(0.1)),
                            _buildStat('Experience', '5 Yrs', Icons.military_tech_rounded, AppColors.primaryPurple),
                          ],
                        ),
                      ],
                    ),
                  ).animate().fade().slideY(begin: 0.1),
                  
                  const SizedBox(height: 32),
                  
                  // Menu Options
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        _buildMenuOption(Icons.verified_user_rounded, 'Service Certificates', AppColors.successGreen),
                        const SizedBox(height: 16),
                        _buildMenuOption(Icons.history_rounded, 'Mission History', AppColors.primaryPurple),
                        const SizedBox(height: 16),
                        _buildMenuOption(Icons.assignment_ind_rounded, 'Documents & Licenses', const Color(0xFF0284C7)),
                      ],
                    ),
                  ).animate().fade(delay: 100.ms).slideY(begin: 0.1),
                  
                  const SizedBox(height: 32),
                  
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Provider.of<ResponderState>(context, listen: false).logout();
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.emergencyRed,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('LOGOUT', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 1.5)),
                    ),
                  ).animate().fade(delay: 200.ms).slideY(begin: 0.1),

                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStat(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 6),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textDark)),
          ],
        ),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textGrey)),
      ],
    );
  }

  Widget _buildMenuOption(IconData icon, String title, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppColors.softShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: iconColor.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark))),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textGrey),
        ],
      ),
    );
  }
}
