import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers/responder_state.dart';

class PatientInfoScreen extends StatelessWidget {
  const PatientInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<ResponderState>(context);
    final data = state.currentMissionData ?? {};
    final userName = data['userName'] ?? 'Unknown Citizen';
    final userPhone = data['userPhone'] ?? 'Unknown Contact';
    final bloodGroup = data['bloodGroup'] ?? 'Unknown Blood Type';
    final medicalConditions = data['medicalConditions'] ?? 'None Reported';
    final age = data['age'] ?? 'N/A';

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // Top Navigation
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: AppColors.primaryPurple.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.textDark),
                      ).animate().scale(curve: Curves.easeOutBack, duration: 300.ms),
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          'PATIENT ICE RECORD',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primaryPurple,
                            letterSpacing: 2.0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 42),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Animated Double Glow Icon
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: const Color(0xFF3B82F6).withOpacity(0.2), blurRadius: 20, spreadRadius: -5),
                    ],
                  ),
                  child: const Icon(Icons.fingerprint_rounded, size: 48, color: Color(0xFF3B82F6)),
                ),
              ).animate().scale(delay: 50.ms, curve: Curves.easeOutBack, duration: 600.ms),
              
              const SizedBox(height: 24),
              
              const Text(
                'Identity Verified',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDark,
                  letterSpacing: -0.5,
                ),
              ).animate().fade().slideY(begin: 0.1),
              
              const SizedBox(height: 36),
              
              // Massive White Data Card
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: AppColors.premiumCardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'MEDICAL ALERTS',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textGrey,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    _buildAlertBox(medicalConditions.toString(), Icons.warning_rounded, AppColors.warningAmber),
                    
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24.0),
                      child: Divider(color: Color(0xFFE2E8F0), thickness: 1.5),
                    ),
                    
                    const Text(
                      'CITIZEN DEMOGRAPHICS',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textGrey,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    _buildInfoRow(Icons.person_rounded, 'Full Name', userName.toString()),
                    _buildDivider(),
                    _buildInfoRow(Icons.cake_rounded, 'Age & Blood', '$age Yrs • $bloodGroup'),
                    _buildDivider(),
                    _buildInfoRow(Icons.contact_phone_rounded, 'Emergency Contact', userPhone.toString()),
                  ],
                ),
              ).animate().fade(delay: 200.ms, duration: 500.ms).slideY(begin: 0.1),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlertBox(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Text(text, style: TextStyle(fontWeight: FontWeight.w800, color: color, fontSize: 15)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String data) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primaryPurpleLight,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primaryPurple, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textGrey),
              ),
              const SizedBox(height: 4),
              Text(
                data,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.textDark, height: 1.3),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Divider(color: AppColors.textGrey.withOpacity(0.1), thickness: 1.5),
    );
  }
}
