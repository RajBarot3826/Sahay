import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_colors.dart';

class WantedPersonDatabaseScreen extends StatelessWidget {
  const WantedPersonDatabaseScreen({super.key});

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
                          'NATIONAL DATABASE',
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
                child: const Text('WANTED\nSUSPECTS', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white, height: 1.1, letterSpacing: -0.5))
                  .animate().fade().slideX(begin: -0.1),
              ),
              
              const SizedBox(height: 32),
              
              // Massive Wanted Card
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: AppColors.premiumCardShadow,
                  border: Border.all(color: AppColors.emergencyRed, width: 4),
                ),
                child: Column(
                  children: [
                    // Top Red Banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: const BoxDecoration(
                        color: AppColors.emergencyRed,
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(28), topRight: Radius.circular(28)),
                      ),
                      child: const Center(
                        child: Text('MOST WANTED', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 4.0)),
                      ),
                    ),
                    
                    Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          // Profile Image with Scan
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.emergencyRed, width: 4),
                                  boxShadow: AppColors.glowRed,
                                  image: const DecorationImage(
                                    image: NetworkImage('https://i.pravatar.cc/300?img=12'),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: -10,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.emergencyRed,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text('REWARD: ₹50,000', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white)),
                                ),
                              ),
                            ],
                          ).animate().scale(delay: 200.ms, curve: Curves.easeOutBack),
                          
                          const SizedBox(height: 32),
                          
                          const Text('VIKRAM SINGH', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.textDark, letterSpacing: -0.5)),
                          const SizedBox(height: 4),
                          const Text('Alias: "Vicky" • Age: 34', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textGrey)),
                          
                          const SizedBox(height: 24),
                          
                          // Details Grid
                          Row(
                            children: [
                              Expanded(child: _buildDetail('Height', '180 cm')),
                              Expanded(child: _buildDetail('Build', 'Athletic')),
                              Expanded(child: _buildDetail('Eyes', 'Brown')),
                            ],
                          ),
                          
                          const SizedBox(height: 24),
                          
                          const Text('WANTED FOR', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.textGrey, letterSpacing: 1.5)),
                          const SizedBox(height: 8),
                          const Text('Armed Robbery, Assault', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.emergencyRed)),
                          
                          const SizedBox(height: 40),
                          
                          // Action Buttons
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(color: AppColors.navyDark, shape: BoxShape.circle, boxShadow: AppColors.softShadow),
                                child: const Icon(Icons.fingerprint_rounded, color: Colors.white, size: 28),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: SizedBox(
                                  height: 60,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sighting logged to central command.')));
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryBlue,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                      elevation: 0,
                                    ),
                                    child: const Text('LOG SIGHTING', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.0)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fade(delay: 400.ms, duration: 600.ms).slideY(begin: 0.1),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetail(String title, String value) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textGrey)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.textDark)),
      ],
    );
  }
}
