import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers/responder_state.dart';
import 'responder_dashboard.dart';

class MissionCompletedScreen extends StatelessWidget {
  const MissionCompletedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<ResponderState>(context);
    final data = state.currentMissionData ?? {};
    final eta = data['etaMins'] != null ? '${data['etaMins']} m' : 'N/A';
    final dist = data['distanceKm'] != null ? '${data['distanceKm']} km' : 'N/A';

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 60),
              
              // Animated Massive Checkmark
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryPurple.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: AppColors.primaryPurple,
                    shape: BoxShape.circle,
                    boxShadow: AppColors.glowPurple,
                  ),
                  child: const Icon(Icons.star_rounded, size: 64, color: Colors.white),
                ),
              ).animate().scale(delay: 50.ms, curve: Curves.easeOutBack, duration: 800.ms),
              
              const SizedBox(height: 32),
              
              const Text(
                'Mission Accomplished',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDark,
                  letterSpacing: -0.5,
                ),
              ).animate().fade(delay: 100.ms).slideY(begin: 0.1),
              
              const SizedBox(height: 8),
              
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.0),
                child: Text(
                  'Another life assisted. Thank you for your service.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textGrey,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ).animate().fade(delay: 200.ms).slideY(begin: 0.1),
              
              const SizedBox(height: 40),
              
              // Massive White Stats Card
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
                      'MISSION SUMMARY',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textGrey,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    Row(
                      children: [
                        Expanded(child: _buildSummaryMetric(Icons.timer_rounded, 'Response Time', eta, AppColors.primaryPurple)),
                        Container(width: 1.5, height: 40, color: AppColors.textGrey.withOpacity(0.1)),
                        Expanded(child: _buildSummaryMetric(Icons.route_rounded, 'Distance Covered', dist, AppColors.warningAmber)),
                      ],
                    ),
                    
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24.0),
                      child: Divider(color: Color(0xFFE2E8F0), thickness: 1.5),
                    ),
                    
                    const Text(
                      'IMPACT GENERATED',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textGrey,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.primaryPurpleLight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('1 Life Assisted', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.primaryPurple, letterSpacing: -1)),
                              SizedBox(height: 4),
                              Text('Added to National Record', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                            ],
                          ),
                          const Icon(Icons.favorite_rounded, color: AppColors.primaryPurple, size: 32),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Powerful Gradient Button
                    SizedBox(
                      width: double.infinity,
                      height: 64,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: AppColors.primaryGradient,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryPurple.withOpacity(0.35),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            final state = Provider.of<ResponderState>(context, listen: false);
                            state.completeMission();
                            Navigator.pushAndRemoveUntil(
                              context, 
                              MaterialPageRoute(builder: (_) => const ResponderDashboard()),
                              (route) => false,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          child: const Text(
                            'RETURN TO HOME',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fade(delay: 300.ms, duration: 500.ms).slideY(begin: 0.1),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryMetric(IconData icon, String title, String value, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 12),
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textDark, letterSpacing: -0.5)),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textGrey)),
      ],
    );
  }
}
