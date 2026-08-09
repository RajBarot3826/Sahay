import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers/emergency_provider.dart';
import '../providers/auth_provider.dart';

class CrashDetectionScreen extends StatefulWidget {
  const CrashDetectionScreen({Key? key}) : super(key: key);

  @override
  State<CrashDetectionScreen> createState() => _CrashDetectionScreenState();
}

class _CrashDetectionScreenState extends State<CrashDetectionScreen> with SingleTickerProviderStateMixin {
  int _countdown = 15;
  Timer? _timer;
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  bool _isCanceled = false;

  @override
  void initState() {
    super.initState();
    
    // Pulsing animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
      } else {
        _timer?.cancel();
        _triggerSOS();
      }
    });
  }

  Future<void> _triggerSOS() async {
    if (_isCanceled) return;
    
    final emergencyProvider = Provider.of<EmergencyProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Show loading overlay
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: AppColors.emergencyRed),
      ),
    );
    
    // Trigger the real SOS flow
    await emergencyProvider.triggerSOS(
      'Vehicle Crash',
      userName: authProvider.userName,
      userPhone: authProvider.userPhone,
      bloodGroup: 'Unknown', // Or fetch from authProvider if available
    );
    
    if (mounted) {
      Navigator.of(context, rootNavigator: true).pop(); // pop loading indicator
      Navigator.of(context).pop(); // pop crash screen
    }
  }

  void _cancelSOS() {
    setState(() {
      _isCanceled = true;
    });
    _timer?.cancel();
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark, // Deep purple/dark background
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              
              // Pulsing Icon
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.emergencyRed.withOpacity(0.15),
                        boxShadow: AppColors.glowRed,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.emergencyRed.withOpacity(0.3),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.emergencyRed,
                          ),
                          child: const Icon(
                            Icons.car_crash,
                            color: AppColors.textLight,
                            size: 80,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 64),
              
              // Warning Text
              const Text(
                'CRASH DETECTED',
                style: TextStyle(
                  color: AppColors.emergencyRed,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              const Text(
                'Auto-triggering SOS in',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 12),
              
              Text(
                '$_countdown s',
                style: const TextStyle(
                  color: AppColors.textLight,
                  fontSize: 56,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const Spacer(),
              
              // Cancel Button
              SizedBox(
                width: double.infinity,
                height: 64,
                child: ElevatedButton(
                  onPressed: _cancelSOS,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.cardPurple,
                    foregroundColor: AppColors.textLight,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: AppColors.brandPurple, width: 2),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "I'm OK - Cancel SOS",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
