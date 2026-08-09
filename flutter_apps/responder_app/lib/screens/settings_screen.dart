import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: AppColors.softShadow),
                        child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.textDark),
                      ),
                    ).animate().scale(curve: Curves.easeOutBack, duration: 300.ms),
                    const Expanded(
                      child: Center(
                        child: Text(
                          'SETTINGS',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.primaryPurple, letterSpacing: 2.0),
                        ),
                      ),
                    ),
                    const SizedBox(width: 42),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 8.0, bottom: 12),
                      child: Text('APP PREFERENCES', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.textGrey, letterSpacing: 1.5)),
                    ),
                    _buildSettingsBlock([
                      _buildSettingRow(Icons.dark_mode_rounded, 'Dark Mode', true),
                      _buildDivider(),
                      _buildSettingRow(Icons.notifications_rounded, 'Push Notifications', true),
                      _buildDivider(),
                      _buildSettingRow(Icons.volume_up_rounded, 'Siren Alerts', true),
                    ]),
                    
                    const SizedBox(height: 32),
                    
                    const Padding(
                      padding: EdgeInsets.only(left: 8.0, bottom: 12),
                      child: Text('ACCOUNT', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.textGrey, letterSpacing: 1.5)),
                    ),
                    _buildSettingsBlock([
                      _buildSettingRow(Icons.security_rounded, 'Privacy & Security', false),
                      _buildDivider(),
                      _buildSettingRow(Icons.language_rounded, 'Language (English)', false),
                      _buildDivider(),
                      _buildSettingRow(Icons.help_rounded, 'Help & Support', false),
                    ]),
                    
                    const SizedBox(height: 40),
                    
                    Center(
                      child: TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          backgroundColor: AppColors.emergencyRedBg,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text('SIGN OUT', style: TextStyle(color: AppColors.emergencyRed, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.0)),
                      ),
                    ).animate().fade(delay: 400.ms),
                    
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsBlock(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        children: children,
      ),
    ).animate().fade().slideY(begin: 0.1);
  }

  Widget _buildSettingRow(IconData icon, String title, bool hasSwitch) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.bgColor, shape: BoxShape.circle),
            child: Icon(icon, color: AppColors.textDark, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark))),
          if (hasSwitch)
            Switch(
              value: true,
              onChanged: (val) {},
              activeColor: AppColors.primaryPurple,
              activeTrackColor: AppColors.primaryPurpleLight,
            )
          else
            const Icon(Icons.chevron_right_rounded, color: AppColors.textGrey),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Divider(color: AppColors.textGrey.withOpacity(0.1), thickness: 1.5, height: 1),
    );
  }
}
