import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_colors.dart';
import 'edar_incident_report_screen.dart';

class EdarReportScreen extends StatelessWidget {
  const EdarReportScreen({super.key});

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
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: AppColors.navyDark, shape: BoxShape.circle, border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.3))),
                        child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.white),
                      ),
                    ).animate().scale(curve: Curves.easeOutBack, duration: 400.ms),
                    const Expanded(
                      child: Center(
                        child: Text(
                          'e-DAR PROTOCOL',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.techCyan, letterSpacing: 2.0),
                        ),
                      ),
                    ),
                    const SizedBox(width: 44),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: const Text('ACCIDENT\nREPORT', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white, height: 1.1, letterSpacing: -0.5))
                  .animate().fade().slideX(begin: -0.1),
              ),
              
              const SizedBox(height: 32),
              
              // Action Cards
              _buildEdarCard(context, 0, Icons.add_chart_rounded, 'START NEW REPORT', 'Initiate an electronic Detailed Accident Report on-site.', AppColors.primaryBlue, () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const EdarIncidentReportScreen()));
              }),
              _buildEdarCard(context, 1, Icons.history_edu_rounded, 'PENDING DRAFTS', 'Continue incomplete reports.', AppColors.warningAmber, () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Loading pending drafts...')));
              }),
              _buildEdarCard(context, 2, Icons.cloud_done_rounded, 'SUBMITTED TO COURT', 'View securely signed past reports.', AppColors.successGreen, () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Accessing securely signed reports...')));
              }),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildEdarCard(BuildContext context, int index, IconData icon, String title, String subtitle, Color accent, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(left: 24, right: 24, bottom: 20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: AppColors.premiumCardShadow,
          border: Border.all(color: accent.withValues(alpha: 0.5), width: 2),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: accent.withValues(alpha: 0.15), shape: BoxShape.circle),
              child: Icon(icon, color: accent, size: 32),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.textDark, letterSpacing: 1.0)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textGrey)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textGrey.withValues(alpha: 0.5), size: 16),
          ],
        ),
      ).animate().fade(delay: (200 + (index * 100)).ms, duration: 600.ms).slideY(begin: 0.1),
    );
  }
}
