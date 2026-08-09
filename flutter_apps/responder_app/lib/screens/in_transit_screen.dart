import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_colors.dart';
import 'hospital_handover_screen.dart';

class InTransitScreen extends StatelessWidget {
  const InTransitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1B4B), // Deep dark map background
      body: Stack(
        children: [
          // Simulated 3D Map Area (Top Half)
          Positioned.fill(
            child: _buildSimulatedMap(),
          ),

          // Top Floating Header
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildFloatingIconButton(Icons.menu_rounded),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))],
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.emergency_share_rounded, color: AppColors.emergencyRed, size: 20),
                      SizedBox(width: 8),
                      Text('Transporting to Hospital', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.textDark, letterSpacing: -0.5)),
                    ],
                  ),
                ).animate().slideY(begin: -1.0, duration: 600.ms, curve: Curves.easeOutBack),
                _buildFloatingIconButton(Icons.local_hospital_rounded),
              ],
            ),
          ),

          // Massive Bottom White Card
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(28, 32, 28, 40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
                boxShadow: [
                  BoxShadow(color: AppColors.primaryPurple.withOpacity(0.15), blurRadius: 40, offset: const Offset(0, -20)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Destination & ETA
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Sir T. General', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.textDark, letterSpacing: -1)),
                            const SizedBox(height: 4),
                            Text('ETA 16:40 • 2.4 km', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primaryPurple.withOpacity(0.8))),
                          ],
                        ),
                      ).animate().fade().slideX(begin: -0.1),
                      
                      // Pre-arrival Alert sent indicator
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.successGreenLight,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.successGreen.withOpacity(0.3)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.check_circle_rounded, color: AppColors.successGreen, size: 16),
                            SizedBox(width: 6),
                            Text('ER Notified', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.successGreen)),
                          ],
                        ),
                      ).animate().fade().slideX(begin: 0.1),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Sirens & Vitals Row
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.emergencyRedBg,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.campaign_rounded, color: AppColors.emergencyRed),
                              SizedBox(width: 8),
                              Text('Sirens ON', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.emergencyRed)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.primaryPurpleLight,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.monitor_heart_rounded, color: AppColors.primaryPurple),
                              SizedBox(width: 8),
                              Text('Vitals Stable', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.primaryPurple)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ).animate().fade(delay: 100.ms).slideY(begin: 0.1),
                  
                  const SizedBox(height: 32),
                  
                  // Massive Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 72,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: const LinearGradient(
                          colors: [AppColors.successGreen, Color(0xFF16A34A)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.successGreen.withOpacity(0.4),
                            blurRadius: 24,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HospitalHandoverScreen()));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        ),
                        child: const Text(
                          'ARRIVED AT HOSPITAL',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.0),
                        ),
                      ),
                    ),
                  ).animate().fade(delay: 200.ms).scale(curve: Curves.easeOutBack),
                ],
              ),
            ).animate().slideY(begin: 1.0, duration: 600.ms, curve: Curves.easeOutCubic),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingIconButton(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Icon(icon, color: AppColors.textDark, size: 24),
    ).animate().scale(curve: Curves.easeOutBack, duration: 400.ms);
  }

  // Placeholder for a dark, glowing 3D Map
  Widget _buildSimulatedMap() {
    return Container(
      color: const Color(0xFF1E1B4B), // Deep navy background
      child: Stack(
        children: [
          // Grid lines
          CustomPaint(painter: _GridPainter(), child: Container()),
          
          // Glowing route line
          Positioned(
            top: 200,
            left: 100,
            child: Container(
              width: 200,
              height: 400,
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(color: AppColors.emergencyRed.withOpacity(0.8), width: 8),
                  bottom: BorderSide(color: AppColors.emergencyRed.withOpacity(0.8), width: 8),
                ),
                boxShadow: [BoxShadow(color: AppColors.emergencyRed.withOpacity(0.5), blurRadius: 30, spreadRadius: 5)],
              ),
            ),
          ),
          
          // Ambulance Marker
          Positioned(
            top: 550,
            left: 80,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.5), blurRadius: 30, spreadRadius: 10)],
              ),
              child: const Icon(Icons.local_hospital_rounded, color: AppColors.emergencyRed, size: 32),
            ).animate().scale(duration: 1000.ms).then().shake(duration: 2000.ms),
          ),
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1.0;
      
    for (double i = 0; i < size.width; i += 40) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += 40) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
