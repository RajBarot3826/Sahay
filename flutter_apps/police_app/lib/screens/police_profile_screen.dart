import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_colors.dart';

class PoliceProfileScreen extends StatelessWidget {
  const PoliceProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: AppColors.navyDark, shape: BoxShape.circle, border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.3))),
                      child: const Icon(Icons.admin_panel_settings_rounded, size: 20, color: Colors.white),
                    ).animate().scale(curve: Curves.easeOutBack, duration: 400.ms),
                    const Expanded(
                      child: Center(
                        child: Text(
                          'OFFICER PROFILE',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.techCyan, letterSpacing: 2.0),
                        ),
                      ),
                    ),
                    const SizedBox(width: 44),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Profile Card
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: AppColors.premiumCardShadow,
                  border: Border.all(color: AppColors.primaryBlueLight, width: 2),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryBlueLight,
                        border: Border.all(color: AppColors.primaryBlue, width: 2),
                        boxShadow: AppColors.innerGlowBlue,
                      ),
                      child: const CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage('https://i.pravatar.cc/300?img=52'),
                      ),
                    ).animate().scale(curve: Curves.easeOutBack, delay: 200.ms),
                    
                    const SizedBox(height: 24),
                    
                    const Text('INSPECTOR R. SHARMA', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.textDark, letterSpacing: -0.5)),
                    const SizedBox(height: 4),
                    const Text('Badge: GJ-4421 • Unit: PCR-44', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textGrey)),
                    
                    const SizedBox(height: 32),
                    
                    // Stats
                    Row(
                      children: [
                        Expanded(child: _buildStat('124', 'Incidents\nHandled')),
                        Container(height: 40, width: 1, color: AppColors.textGrey.withValues(alpha: 0.2)),
                        Expanded(child: _buildStat('98%', 'Clearance\nRate')),
                        Container(height: 40, width: 1, color: AppColors.textGrey.withValues(alpha: 0.2)),
                        Expanded(child: _buildStat('4.2m', 'Avg\nResponse')),
                      ],
                    ),
                  ],
                ),
              ).animate().fade(delay: 200.ms, duration: 600.ms).slideY(begin: 0.1),
              
              const SizedBox(height: 32),
              
              // Actions
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    _buildActionTile(Icons.shield_rounded, 'Shift Schedule', 'View upcoming patrols', AppColors.primaryBlue),
                    _buildActionTile(Icons.history_rounded, 'Incident History', 'Review past reports', AppColors.warningAmber),
                    _buildActionTile(Icons.settings_rounded, 'Settings', 'App preferences', AppColors.textGrey),
                    const SizedBox(height: 24),
                    _buildActionTile(Icons.logout_rounded, 'Sign Out', 'End active session', AppColors.emergencyRed),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.primaryBlue, letterSpacing: -1.0)),
        const SizedBox(height: 4),
        Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textGrey, height: 1.2)),
      ],
    );
  }
  
  Widget _buildActionTile(IconData icon, String title, String subtitle, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.navyDark,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.1)),
        boxShadow: AppColors.softShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textGrey)),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textGrey.withValues(alpha: 0.5), size: 16),
        ],
      ),
    ).animate().fade().slideX(begin: 0.1);
  }
}
