import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_colors.dart';
import 'police_login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 800),
          pageBuilder: (_, __, ___) => const PoliceLoginScreen(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: Stack(
        children: [
          // Background Gradient Glow
          Positioned(
            top: -100,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryBlue.withValues(alpha: 0.15),
                boxShadow: [
                  BoxShadow(color: AppColors.primaryBlue.withValues(alpha: 0.2), blurRadius: 100, spreadRadius: 50)
                ],
              ),
            ),
          ).animate(onPlay: (controller) => controller.repeat(reverse: true)).fade(duration: 2.seconds),
          
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Glowing Shield Logo
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.navyDark,
                    shape: BoxShape.circle,
                    boxShadow: AppColors.innerGlowBlue,
                    border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.3), width: 2),
                  ),
                  child: const Icon(
                    Icons.shield_rounded,
                    size: 80,
                    color: AppColors.primaryBlueLight,
                  ),
                )
                .animate()
                .scale(curve: Curves.easeOutBack, duration: 800.ms)
                .then(delay: 200.ms)
                .shimmer(duration: 1000.ms, color: Colors.white),

                const SizedBox(height: 32),

                // Title
                const Text(
                  'SAHAY',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 8.0,
                  ),
                )
                .animate()
                .fade(delay: 400.ms, duration: 600.ms)
                .slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic),
                
                const SizedBox(height: 8),

                // Subtitle
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.emergencyRed.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.emergencyRed.withValues(alpha: 0.3)),
                  ),
                  child: const Text(
                    'POLICE CONTROL ROOM',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.emergencyRed,
                      letterSpacing: 2.0,
                    ),
                  ),
                )
                .animate()
                .fade(delay: 600.ms, duration: 600.ms)
                .slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic),
              ],
            ),
          ),
          
          // Bottom loading indicator
          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: Column(
              children: [
                const SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    color: AppColors.primaryBlue,
                    strokeWidth: 3,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Establishing secure connection...',
                  style: TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ).animate().fade(delay: 1000.ms, duration: 600.ms),
          ),
        ],
      ),
    );
  }
}
