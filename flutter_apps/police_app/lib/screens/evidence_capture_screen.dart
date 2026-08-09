import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_colors.dart';

class EvidenceCaptureScreen extends StatelessWidget {
  const EvidenceCaptureScreen({super.key});

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
                          'EVIDENCE VAULT',
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
                child: const Text('CAPTURE\nEVIDENCE', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white, height: 1.1, letterSpacing: -0.5))
                  .animate().fade().slideX(begin: -0.1),
              ),
              
              const SizedBox(height: 32),
              
              // Massive White Card
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('INCIDENT REF:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.textGrey, letterSpacing: 1.5)),
                    const SizedBox(height: 8),
                    const Text('CR-491-2024-X', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.textDark, letterSpacing: 1.0)),
                    
                    const SizedBox(height: 32),
                    
                    // Upload Zones
                    Row(
                      children: [
                        Expanded(child: _buildUploadZone(Icons.camera_alt_rounded, 'Photo')),
                        const SizedBox(width: 16),
                        Expanded(child: _buildUploadZone(Icons.videocam_rounded, 'Video')),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildUploadZone(Icons.mic_rounded, 'Audio')),
                        const SizedBox(width: 16),
                        Expanded(child: _buildUploadZone(Icons.description_rounded, 'Document')),
                      ],
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Blockchain Verification Note
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.successGreenLight.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.successGreen.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.verified_user_rounded, color: AppColors.successGreen, size: 24),
                          const SizedBox(width: 12),
                          Expanded(
                            child: const Text(
                              'All captured evidence is cryptographically signed and hashed to the BPRD blockchain.',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textDark),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fade(delay: 200.ms, duration: 600.ms).slideY(begin: 0.1),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildUploadZone(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: AppColors.primaryBlueLight.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.1), width: 2),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: AppColors.primaryBlue),
          const SizedBox(height: 12),
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textDark)),
        ],
      ),
    );
  }
}
