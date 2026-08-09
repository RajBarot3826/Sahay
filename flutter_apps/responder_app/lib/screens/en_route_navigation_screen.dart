import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers/responder_state.dart';
import 'on_scene_actions_screen.dart';

class EnRouteNavigationScreen extends StatefulWidget {
  const EnRouteNavigationScreen({super.key});

  @override
  State<EnRouteNavigationScreen> createState() => _EnRouteNavigationScreenState();
}

class _EnRouteNavigationScreenState extends State<EnRouteNavigationScreen> {
  void _arriveAtScene() {
    final state = Provider.of<ResponderState>(context, listen: false);
    state.updateMissionPhase('on_scene');
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const OnSceneActionsScreen()));
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    var p = 0.017453292519943295;
    var c = math.cos;
    var a = 0.5 - c((lat2 - lat1) * p)/2 + 
            c(lat1 * p) * c(lat2 * p) * 
            (1 - c((lon2 - lon1) * p))/2;
    return 12742 * math.asin(math.sqrt(a));
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<ResponderState>(context);
    final data = state.currentMissionData ?? {};
    
    double dist = 0.0;
    int eta = 0;
    if (data['latitude'] != null && data['longitude'] != null && state.hasLocation) {
      dist = _calculateDistance(state.currentLat, state.currentLng, data['latitude'], data['longitude']);
      eta = (dist / 30 * 60).ceil();
    }

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
                      Icon(Icons.directions_rounded, color: AppColors.primaryPurple, size: 20),
                      SizedBox(width: 8),
                      Text('En-Route to Scene', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.textDark, letterSpacing: -0.5)),
                    ],
                  ),
                ).animate().slideY(begin: -1.0, duration: 600.ms, curve: Curves.easeOutBack),
                _buildFloatingIconButton(Icons.volume_up_rounded),
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
                  // ETA and Distance Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('$eta min', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: AppColors.primaryPurple, letterSpacing: -2)),
                          Text('${dist.toStringAsFixed(1)} km to scene', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark.withOpacity(0.7))),
                        ],
                      ).animate().fade().slideX(begin: -0.1),
                      
                      // Speed indicator
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.primaryPurpleLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Column(
                          children: [
                            Text('65', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.primaryPurple, letterSpacing: -1)),
                            Text('km/h', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textGrey)),
                          ],
                        ),
                      ).animate().fade().slideX(begin: 0.1),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Next Turn Indicator
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.bgColor,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.black.withOpacity(0.05)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.turn_right_rounded, size: 36, color: AppColors.textDark),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('In 300 meters', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textGrey, letterSpacing: 1.0)),
                              Text('Turn Right on Waghawadi Rd', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textDark, letterSpacing: -0.5)),
                            ],
                          ),
                        ),
                      ],
                    ),
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
                        onPressed: _arriveAtScene,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        ),
                        child: const Text(
                          'ARRIVED AT SCENE',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.0),
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
                  left: BorderSide(color: AppColors.primaryPurple.withOpacity(0.8), width: 8),
                  bottom: BorderSide(color: AppColors.primaryPurple.withOpacity(0.8), width: 8),
                ),
                boxShadow: [BoxShadow(color: AppColors.primaryPurple.withOpacity(0.5), blurRadius: 30, spreadRadius: 5)],
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
              child: const Icon(Icons.local_hospital_rounded, color: AppColors.primaryPurple, size: 32),
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
