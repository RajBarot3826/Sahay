// Flutter Screen 21: Settings (Fully Functional)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers/auth_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool voiceGuidance = true;
  bool darkMode = false;
  bool emergencyAlerts = true;
  String selectedLanguage = 'English';

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Select App Language', style: TextStyle(fontWeight: FontWeight.bold)),
        children: ['English', 'Gujarati (ગુજરાતી)', 'Hindi (हिंदी)'].map((lang) {
          return SimpleDialogOption(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            onPressed: () {
              setState(() => selectedLanguage = lang.split(' ')[0]);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Language set to $lang')),
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(lang, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                if (selectedLanguage == lang.split(' ')[0])
                  const Icon(Icons.check_circle_rounded, color: AppColors.brandPurple),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showPrivacyInfo() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('PRIVACY & GOOD SAMARITAN LAW', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.brandPurple)),
            const SizedBox(height: 12),
            const Text(
              'Under Section 134A of the Motor Vehicles Act 2019 & Supreme Court 2016 Guidelines:\n\n'
              '• Bystanders offering help are immune from civil & criminal liability.\n'
              '• You are not forced to give personal details at hospitals or police stations.\n'
              '• Sahay encrypts all telematics and user logs 24/7.',
              style: TextStyle(height: 1.5, color: AppColors.textDark, fontSize: 14),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.brandPurple),
                onPressed: () => Navigator.pop(ctx),
                child: const Text('I UNDERSTAND', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHelpCenter() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sahay Emergency Helpline'),
        content: const Text('For critical system support or feedback, contact 108 Emergency Control Room or call National Highway Lifeline 1033.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
        ],
      ),
    );
  }

  void _showLogoutDialog(AuthProvider auth) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Row(
            children: [
              Icon(Icons.logout_rounded, color: AppColors.emergencyRed),
              SizedBox(width: 12),
              Text('Confirm Logout', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: const Text('Are you sure you want to log out? You will need to sign in again with your phone number and OTP.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.emergencyRed,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                Navigator.pop(dialogContext);
                await auth.logout();
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(context, '/registration', (route) => false);
                }
              },
              child: const Text('LOGOUT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    final auth = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Text('SETTINGS', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
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
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24),
          children: [
            const Text('PREFERENCES', style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const SizedBox(height: 16),
            _buildClickTile(Icons.language_rounded, 'Language', selectedLanguage, onTap: _showLanguageDialog),
            _buildSwitchTile(Icons.record_voice_over_rounded, 'Voice Guidance', voiceGuidance, (v) => setState(() => voiceGuidance = v)),
            _buildSwitchTile(Icons.dark_mode_rounded, 'Dark Mode', darkMode, (v) => setState(() => darkMode = v)),
            
            const SizedBox(height: 32),
            const Text('SECURITY & ALERTS', style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const SizedBox(height: 16),
            _buildClickTile(Icons.lock_rounded, 'Privacy & Security', '', onTap: _showPrivacyInfo),
            _buildSwitchTile(Icons.notifications_active_rounded, 'Emergency Alerts', emergencyAlerts, (v) => setState(() => emergencyAlerts = v)),
            
            const SizedBox(height: 32),
            const Text('SUPPORT', style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const SizedBox(height: 16),
            _buildClickTile(Icons.help_center_rounded, 'Help Center', '', onTap: _showHelpCenter),
            _buildClickTile(Icons.info_rounded, 'About App', 'v1.0.0', onTap: () {
              showAboutDialog(context: context, applicationName: 'Sahay Golden Hour', applicationVersion: '1.0.0');
            }),

            const SizedBox(height: 32),
            const Text('ACCOUNT ACTION', style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const SizedBox(height: 16),
            _buildClickTile(
              Icons.logout_rounded, 
              'Logout Account', 
              '', 
              color: AppColors.emergencyRed, 
              isDestructive: true, 
              onTap: () => _showLogoutDialog(auth),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildClickTile(IconData icon, String title, String trailingText, {required VoidCallback onTap, Color color = AppColors.brandPurple, bool isDestructive = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDestructive ? AppColors.emergencyRedBg : AppColors.brandPurpleLight,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: isDestructive ? AppColors.emergencyRed : color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(title, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: isDestructive ? AppColors.emergencyRed : AppColors.textDark)),
                ),
                if (trailingText.isNotEmpty)
                  Text(trailingText, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
                if (trailingText.isNotEmpty) const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textSecondary, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile(IconData icon, String title, bool val, Function(bool) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.softShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => onChanged(!val),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(color: AppColors.brandPurpleLight, shape: BoxShape.circle),
                  child: Icon(icon, color: AppColors.brandPurple, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.textDark)),
                ),
                Switch(
                  value: val,
                  onChanged: onChanged,
                  activeColor: AppColors.brandPurple,
                  activeTrackColor: AppColors.brandPurpleLight,
                  inactiveThumbColor: AppColors.textSecondary,
                  inactiveTrackColor: AppColors.bgLight,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
