import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import '../constants/app_colors.dart';
import 'police_dashboard.dart';

class PoliceLoginScreen extends StatefulWidget {
  const PoliceLoginScreen({super.key});

  @override
  State<PoliceLoginScreen> createState() => _PoliceLoginScreenState();
}

class _PoliceLoginScreenState extends State<PoliceLoginScreen> {
  final _badgeController = TextEditingController();
  final _pinController = TextEditingController();
  bool _isLoading = false;

  void _handleLogin() {
    setState(() => _isLoading = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 800),
          pageBuilder: (_, __, ___) => const PoliceDashboard(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    });
  }

  @override
  void dispose() {
    _badgeController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Deep Rich Animated Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF070B19), // Ultra dark navy
                  Color(0xFF0F172A), // Dark slate
                  Color(0xFF1E3A8A), // Deep Royal Blue accent
                ],
                stops: [0.0, 0.6, 1.0],
              ),
            ),
          ),

          // 2. Glowing Tech Orbs (Background ambient lighting)
          Positioned(
            top: -150,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryBlue.withValues(alpha: 0.15),
                boxShadow: [
                  BoxShadow(color: AppColors.primaryBlue.withValues(alpha: 0.2), blurRadius: 120, spreadRadius: 60)
                ],
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(duration: 4.seconds, begin: const Offset(1,1), end: const Offset(1.2, 1.2)),
          ),
          
          Positioned(
            bottom: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.emergencyRed.withValues(alpha: 0.1),
                boxShadow: [
                  BoxShadow(color: AppColors.emergencyRed.withValues(alpha: 0.15), blurRadius: 100, spreadRadius: 40)
                ],
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(duration: 5.seconds, begin: const Offset(1,1), end: const Offset(1.3, 1.3)),
          ),
          
          // 3. Grid Pattern Overlay (Tech feel)
          Positioned.fill(
            child: Opacity(
              opacity: 0.03,
              child: Image.network(
                'https://www.transparenttextures.com/patterns/cubes.png',
                repeat: ImageRepeat.repeat,
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Header - Centralized and Massive
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.navyDarker.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.5), width: 2),
                          boxShadow: AppColors.innerGlowBlue,
                        ),
                        child: const Icon(Icons.local_police_rounded, size: 64, color: Colors.white),
                      )
                      .animate()
                      .scale(curve: Curves.easeOutBack, duration: 800.ms)
                      .then(delay: 200.ms)
                      .shimmer(duration: 1000.ms, color: AppColors.primaryBlueLight),
                      
                      const SizedBox(height: 32),
                      
                      const Text('SAHAY PCR', style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: Colors.white, height: 1.1, letterSpacing: 4.0))
                        .animate().fade(delay: 200.ms).slideY(begin: 0.2),
                        
                      const SizedBox(height: 8),
                      
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.5)),
                        ),
                        child: const Text('SECURE COMMAND PORTAL', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.techCyan, letterSpacing: 2.0)),
                      ).animate().fade(delay: 400.ms).slideY(begin: 0.2),
                        
                      const SizedBox(height: 56),
                      
                      // Massive Glassmorphism Card
                      ClipRRect(
                        borderRadius: BorderRadius.circular(40),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15), // Slight transparency for glass effect
                              borderRadius: BorderRadius.circular(40),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 50,
                                  offset: const Offset(0, 20),
                                )
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('AUTHORIZATION', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.primaryBlue, letterSpacing: 2.0)),
                                const SizedBox(height: 24),
                                
                                const Text('BADGE ID', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.textGrey, letterSpacing: 1.5)),
                                const SizedBox(height: 8),
                                _buildTextField(_badgeController, 'e.g. GJ-4421', Icons.badge_rounded, false),
                                
                                const SizedBox(height: 24),
                                
                                const Text('SECURITY PIN', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.textGrey, letterSpacing: 1.5)),
                                const SizedBox(height: 8),
                                _buildTextField(_pinController, '••••••', Icons.lock_rounded, true),
                                
                                const SizedBox(height: 40),
                                
                                // Massive Action Button
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
                                      onPressed: _isLoading ? null : _handleLogin,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                      ),
                                      child: _isLoading 
                                        ? const SizedBox(width: 28, height: 28, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                                        : const Text('INITIATE SECURE LINK', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.5)),
                                    ),
                                  ),
                                ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(begin: const Offset(1,1), end: const Offset(1.02, 1.02), duration: 1000.ms),
                              ],
                            ),
                          ),
                        ),
                      ).animate().fade(delay: 600.ms, duration: 800.ms).slideY(begin: 0.1, curve: Curves.easeOutCubic),
                      
                      const SizedBox(height: 48),
                      
                      // Bottom Security Text
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shield_rounded, color: AppColors.textGrey.withValues(alpha: 0.5), size: 16),
                          const SizedBox(width: 8),
                          Text('256-bit Encrypted Government Channel', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textGrey.withValues(alpha: 0.5), letterSpacing: 0.5)),
                        ],
                      ).animate().fade(delay: 1000.ms),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, bool isPassword) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgColor.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.15), width: 2),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark, letterSpacing: 1.0),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: AppColors.textGrey.withValues(alpha: 0.4), fontWeight: FontWeight.w600, letterSpacing: 1.0),
          prefixIcon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Icon(icon, color: AppColors.primaryBlue, size: 24),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        ),
      ),
    );
  }
}
