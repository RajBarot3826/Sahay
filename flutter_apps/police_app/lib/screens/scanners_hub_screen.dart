import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_colors.dart';
import 'field_qr_scanner_screen.dart';
import 'stolen_vehicle_screen.dart';
import 'wanted_person_database_screen.dart';
import 'evidence_capture_screen.dart';

class ScannersHubScreen extends StatelessWidget {
  const ScannersHubScreen({super.key});

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
                      child: const Icon(Icons.grid_view_rounded, size: 20, color: Colors.white),
                    ).animate().scale(curve: Curves.easeOutBack, duration: 400.ms),
                    const Expanded(
                      child: Center(
                        child: Text(
                          'FIELD TOOLS',
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
                child: const Text('SCANNERS &\nDATABASE', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white, height: 1.1, letterSpacing: -0.5))
                  .animate().fade().slideX(begin: -0.1),
              ),
              
              const SizedBox(height: 32),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                  children: [
                    _buildScannerCard(context, 0, 'ALPR Scanner', 'Stolen Vehicle', Icons.directions_car_rounded, AppColors.emergencyRed, () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const StolenVehicleScreen()));
                    }),
                    _buildScannerCard(context, 1, 'QR Verify', 'Citizen ID', Icons.qr_code_scanner_rounded, AppColors.primaryBlue, () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const FieldQrScannerScreen()));
                    }),
                    _buildScannerCard(context, 2, 'Wanted DB', 'Suspects', Icons.person_search_rounded, AppColors.warningAmber, () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const WantedPersonDatabaseScreen()));
                    }),
                    _buildScannerCard(context, 3, 'Evidence', 'Secure Vault', Icons.camera_alt_rounded, AppColors.techCyan, () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const EvidenceCaptureScreen()));
                    }),
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

  Widget _buildScannerCard(BuildContext context, int index, String title, String subtitle, IconData icon, Color accent, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: AppColors.premiumCardShadow,
          border: Border.all(color: accent.withValues(alpha: 0.3), width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: accent.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, color: accent, size: 32),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(subtitle, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.textGrey, letterSpacing: 1.0)),
                const SizedBox(height: 4),
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.textDark, letterSpacing: -0.5, height: 1.1)),
              ],
            ),
          ],
        ),
      ).animate().fade(delay: (200 + (index * 100)).ms, duration: 600.ms).scale(curve: Curves.easeOutBack, begin: const Offset(0.8, 0.8)),
    );
  }
}
