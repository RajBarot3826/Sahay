import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_colors.dart';
import 'hospital_selection_screen.dart';

class OnSceneActionsScreen extends StatefulWidget {
  const OnSceneActionsScreen({super.key});

  @override
  State<OnSceneActionsScreen> createState() => _OnSceneActionsScreenState();
}

class _OnSceneActionsScreenState extends State<OnSceneActionsScreen> {
  final Map<String, bool> _actionsCompleted = {
    'cpr': false,
    'oxygen': false,
    'id_scan': false,
  };
  DateTime? _startTime;
  Timer? _timer;
  String _elapsedTime = '00:00';

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      final diff = now.difference(_startTime!);
      final minutes = diff.inMinutes.remainder(60).toString().padLeft(2, '0');
      final seconds = diff.inSeconds.remainder(60).toString().padLeft(2, '0');
      if (mounted) {
        setState(() {
          _elapsedTime = '$minutes:$seconds';
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _beginTransport() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HospitalSelectionScreen()));
  }

  void _toggleAction(String key) {
    setState(() {
      _actionsCompleted[key] = !_actionsCompleted[key]!;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                    const SizedBox(width: 42), // Spacer for centering
                    const Expanded(
                      child: Center(
                        child: Text(
                          'ON-SCENE PROTOCOL',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primaryPurple,
                            letterSpacing: 2.0,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.emergencyRedBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.timer_rounded, color: AppColors.emergencyRed, size: 14),
                          const SizedBox(width: 4),
                          Text(_elapsedTime, style: const TextStyle(color: AppColors.emergencyRed, fontWeight: FontWeight.w900, fontSize: 14)),
                        ],
                      ),
                    ).animate().fade().slideX(begin: 0.1),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Animated Double Glow Icon
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.successGreen.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.successGreenLight,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: AppColors.successGreen.withOpacity(0.2), blurRadius: 20, spreadRadius: -5),
                    ],
                  ),
                  child: const Icon(Icons.health_and_safety_rounded, size: 48, color: AppColors.successGreen),
                ),
              ).animate().scale(delay: 50.ms, curve: Curves.easeOutBack, duration: 600.ms),
              
              const SizedBox(height: 24),
              
              const Text(
                'Arrived at Scene',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDark,
                  letterSpacing: -0.5,
                ),
              ).animate().fade().slideY(begin: 0.1),
              
              const SizedBox(height: 8),
              
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 32.0),
                child: Text(
                  'Assess the victim and log initial treatments before transport.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textGrey,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ).animate().fade(delay: 100.ms).slideY(begin: 0.1),
              
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
                      'MEDICAL ASSESSMENT',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textGrey,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    _buildActionToggle('cpr', Icons.favorite_rounded, 'Start CPR / Defibrillation', 'Vital signs critical'),
                    const SizedBox(height: 16),
                    _buildActionToggle('oxygen', Icons.air_rounded, 'Administer Oxygen', 'Flow rate adjusted'),
                    const SizedBox(height: 16),
                    _buildActionToggle('id_scan', Icons.document_scanner_rounded, 'Scan Patient ID', 'Link to Citizen Profile'),
                    
                    const SizedBox(height: 40),
                    
                    // Powerful Gradient Button
                    SizedBox(
                      width: double.infinity,
                      height: 64,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)], // Vibrant Blue Gradient
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF3B82F6).withOpacity(0.35),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _beginTransport,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'BEGIN TRANSPORT',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5),
                              ),
                              SizedBox(width: 12),
                              Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 24),
                            ],
                          ),
                        ),
                      ),
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

  Widget _buildActionToggle(String key, IconData icon, String title, String subtitle) {
    bool isCompleted = _actionsCompleted[key] ?? false;
    
    return GestureDetector(
      onTap: () => _toggleAction(key),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isCompleted ? AppColors.successGreenLight : AppColors.primaryPurpleLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isCompleted ? AppColors.successGreen.withOpacity(0.3) : Colors.transparent, width: 2),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isCompleted ? AppColors.successGreen : AppColors.primaryPurple,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: isCompleted ? AppColors.successGreen : AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isCompleted ? 'Completed' : subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isCompleted ? AppColors.successGreen.withOpacity(0.8) : AppColors.textGrey,
                    ),
                  ),
                ],
              ),
            ),
            if (isCompleted)
              const Icon(Icons.check_circle_rounded, color: AppColors.successGreen, size: 28)
                  .animate().scale(curve: Curves.easeOutBack, duration: 300.ms),
          ],
        ),
      ),
    );
  }
}
