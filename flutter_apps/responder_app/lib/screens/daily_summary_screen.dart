import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers/responder_state.dart';

class DailySummaryScreen extends StatelessWidget {
  const DailySummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<ResponderState>(context);
    
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
                          'DAILY REPORT',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.primaryPurple, letterSpacing: 2.0),
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
                decoration: BoxDecoration(color: AppColors.primaryPurple.withOpacity(0.05), shape: BoxShape.circle),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(color: AppColors.primaryPurpleLight, shape: BoxShape.circle, boxShadow: AppColors.innerGlowPurple),
                  child: const Icon(Icons.bar_chart_rounded, size: 48, color: AppColors.primaryPurple),
                ),
              ).animate().scale(delay: 50.ms, curve: Curves.easeOutBack, duration: 600.ms),
              
              const SizedBox(height: 24),
              
              const Text('Oct 12, 2026', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.textDark, letterSpacing: -0.5)).animate().fade().slideY(begin: 0.1),
              
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
                    const Text('PERFORMANCE', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.textGrey, letterSpacing: 1.5)),
                    const SizedBox(height: 24),
                    
                    Row(
                      children: [
                        Expanded(child: _buildMetric('Missions', '${state.completedMissionsCount}', Icons.medical_services_rounded, AppColors.primaryPurple)),
                        Container(width: 1.5, height: 40, color: AppColors.textGrey.withOpacity(0.1)),
                        Expanded(child: _buildMetric('Avg Time', '8m', Icons.timer_rounded, const Color(0xFF0284C7))),
                      ],
                    ),
                    
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24.0),
                      child: Divider(color: Color(0xFFE2E8F0), thickness: 1.5),
                    ),
                    
                    const Text('CHART OVERVIEW', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.textGrey, letterSpacing: 1.5)),
                    const SizedBox(height: 24),
                    
                    // Simulated chart
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildChartBar(0.4, '8 AM'),
                        _buildChartBar(0.7, '10 AM'),
                        _buildChartBar(0.9, '12 PM', true),
                        _buildChartBar(0.3, '2 PM'),
                        _buildChartBar(0.6, '4 PM'),
                      ],
                    ),
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

  Widget _buildMetric(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 12),
        Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.textDark, letterSpacing: -0.5)),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textGrey)),
      ],
    );
  }

  Widget _buildChartBar(double heightFactor, String label, [bool highlight = false]) {
    return Column(
      children: [
        Container(
          width: 24,
          height: 100 * heightFactor,
          decoration: BoxDecoration(
            color: highlight ? AppColors.primaryPurple : AppColors.primaryPurpleLight,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        const SizedBox(height: 12),
        Text(label, style: TextStyle(fontSize: 10, fontWeight: highlight ? FontWeight.w900 : FontWeight.w700, color: highlight ? AppColors.primaryPurple : AppColors.textGrey)),
      ],
    );
  }
}
