// Flutter Screen 24: Impact Profile & Badges (Exact Match to Image 1)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';

class ImpactProfileScreen extends StatelessWidget {
  const ImpactProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: const Text('IMPACT PROFILE', style: TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: AppColors.bgCardDark, shape: BoxShape.circle, border: Border.all(color: Colors.white12)),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          children: [
            // Profile Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.bgCardDark, Color(0xFF1F1433)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white12),
                boxShadow: [BoxShadow(color: AppColors.brandPurple.withAlpha(20), blurRadius: 30)],
              ),
              child: Row(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.primaryGradient,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [BoxShadow(color: AppColors.brandPurple.withAlpha(100), blurRadius: 10)],
                    ),
                    child: const Icon(Icons.person_rounded, color: Colors.white, size: 36),
                  ),
                  const SizedBox(width: 20),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Raj Barot', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: Colors.white, letterSpacing: -0.5)),
                        SizedBox(height: 4),
                        Text('First Responder Hero', style: TextStyle(color: AppColors.primaryPurpleLight, fontSize: 13, fontWeight: FontWeight.bold)),
                        SizedBox(height: 2),
                        Text('Bhavnagar Chapter', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Impact Metrics Grid
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('LIFETIME METRICS', style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildMetricCard('832', 'Lives Impacted', AppColors.successGreen, Icons.favorite_rounded),
                const SizedBox(width: 12),
                _buildMetricCard('1245', 'Incidents Reported', AppColors.infoBlue, Icons.campaign_rounded),
              ],
            ),
            const SizedBox(height: 32),

            // Badges Section
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('EARNED BADGES & CERTIFICATES', style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.bgCardDark,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildBadgeItem(Icons.workspace_premium_rounded, 'First\nResponder', AppColors.warningAmber),
                  _buildBadgeItem(Icons.favorite_rounded, 'Life\nSaver', AppColors.emergencyRed),
                  _buildBadgeItem(Icons.volunteer_activism_rounded, 'CPR\nHero', AppColors.brandPurpleLight),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  side: const BorderSide(color: Colors.white24, width: 2),
                ),
                onPressed: () { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Action executed successfully'))); },
                icon: const Icon(Icons.share_rounded, color: Colors.white),
                label: const Text('Share Impact Profile', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String value, String label, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.bgCardDark,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withAlpha(20), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 16),
            Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 26, color: color, letterSpacing: -0.5)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgeItem(IconData icon, String label, Color color) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: color.withAlpha(20),
            shape: BoxShape.circle,
            border: Border.all(color: color.withAlpha(100), width: 2),
            boxShadow: [BoxShadow(color: color.withAlpha(30), blurRadius: 15)],
          ),
          child: Icon(icon, color: color, size: 32),
        ),
        const SizedBox(height: 12),
        Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w800, height: 1.2)),
      ],
    );
  }
}
