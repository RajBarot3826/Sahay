import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_colors.dart';

class StolenVehicleScreen extends StatefulWidget {
  const StolenVehicleScreen({super.key});

  @override
  State<StolenVehicleScreen> createState() => _StolenVehicleScreenState();
}

class _StolenVehicleScreenState extends State<StolenVehicleScreen> {
  final _plateController = TextEditingController();

  @override
  void dispose() {
    _plateController.dispose();
    super.dispose();
  }

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
                          'ALPR SCANNER',
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
                child: const Text('STOLEN\nVEHICLE DB', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white, height: 1.1, letterSpacing: -0.5))
                  .animate().fade().slideX(begin: -0.1),
              ),
              
              const SizedBox(height: 32),
              
              // Massive Vehicle Scan Card
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
                  children: [
                    // Mock Camera Viewport
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.navyDarker,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.primaryBlue, width: 2),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(Icons.camera_alt_rounded, size: 64, color: AppColors.primaryBlue.withValues(alpha: 0.3)),
                          // Scanner Line Animation
                          Positioned(
                            top: 20,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 2,
                              decoration: BoxDecoration(
                                color: AppColors.techCyan,
                                boxShadow: [BoxShadow(color: AppColors.techCyan, blurRadius: 10, spreadRadius: 2)],
                              ),
                            ).animate(onPlay: (c) => c.repeat(reverse: true)).slideY(begin: 0, end: 150, duration: 1500.ms),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Input Field
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlueLight.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.1), width: 2),
                      ),
                      child: TextField(
                        controller: _plateController,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.textDark, letterSpacing: 2.0),
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                          hintText: 'GJ-XX-XXXX',
                          hintStyle: TextStyle(color: Colors.black26),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Check Database Button
                    SizedBox(
                      width: double.infinity,
                      height: 64,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: AppColors.policeGradient,
                          boxShadow: AppColors.innerGlowBlue,
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Verifying plate against National Database...')));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          child: const Text('VERIFY PLATE STATUS', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.0)),
                        ),
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
}
