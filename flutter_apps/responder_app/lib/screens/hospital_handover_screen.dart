import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_colors.dart';
import 'mission_completed_screen.dart';

class HospitalHandoverScreen extends StatefulWidget {
  const HospitalHandoverScreen({super.key});

  @override
  State<HospitalHandoverScreen> createState() => _HospitalHandoverScreenState();
}

class _HospitalHandoverScreenState extends State<HospitalHandoverScreen> {
  final Map<String, bool> _handoverTasks = {
    'patient_transfer': false,
    'vitals_log': false,
    'signature': false,
  };

  void _completeMission() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MissionCompletedScreen()));
  }

  void _toggleTask(String key) {
    setState(() {
      _handoverTasks[key] = !_handoverTasks[key]!;
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
                    const SizedBox(width: 42),
                    const Expanded(
                      child: Center(
                        child: Text(
                          'ER HANDOVER',
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
                  color: AppColors.warningAmber.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: AppColors.warningAmber.withOpacity(0.2), blurRadius: 20, spreadRadius: -5),
                    ],
                  ),
                  child: const Icon(Icons.assignment_turned_in_rounded, size: 48, color: AppColors.warningAmber),
                ),
              ).animate().scale(delay: 50.ms, curve: Curves.easeOutBack, duration: 600.ms),
              
              const SizedBox(height: 24),
              
              const Text(
                'Hospital Handover',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDark,
                  letterSpacing: -0.5,
                ),
              ).animate().fade().slideY(begin: 0.1),
              
              const SizedBox(height: 8),
              
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.0),
                child: Text(
                  'Complete the final transfer protocol with the emergency room staff.',
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
                      'HANDOVER CHECKLIST',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textGrey,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    _buildTaskToggle('patient_transfer', Icons.wheelchair_pickup_rounded, 'Patient Transferred', 'To ER Trauma Bed 4'),
                    const SizedBox(height: 16),
                    _buildTaskToggle('vitals_log', Icons.monitor_heart_rounded, 'Vitals Log Synced', 'Transmitted to hospital system'),
                    const SizedBox(height: 16),
                    _buildTaskToggle('signature', Icons.draw_rounded, 'Doctor Signature', 'Dr. Mehta (ER Head)'),
                    
                    const SizedBox(height: 40),
                    
                    // Powerful Gradient Button
                    SizedBox(
                      width: double.infinity,
                      height: 64,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: const LinearGradient(
                            colors: [AppColors.successGreen, Color(0xFF16A34A)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.successGreen.withOpacity(0.35),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _completeMission,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          child: const Text(
                            'COMPLETE MISSION',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5),
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

  Widget _buildTaskToggle(String key, IconData icon, String title, String subtitle) {
    bool isCompleted = _handoverTasks[key] ?? false;
    
    return GestureDetector(
      onTap: () => _toggleTask(key),
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
                    subtitle,
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
