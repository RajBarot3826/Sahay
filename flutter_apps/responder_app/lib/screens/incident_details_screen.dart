import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_colors.dart';
import 'en_route_navigation_screen.dart';

class IncidentDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> emergencyData;
  const IncidentDetailsScreen({super.key, required this.emergencyData});

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
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: AppColors.primaryPurple.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.textDark),
                      ).animate().scale(curve: Curves.easeOutBack, duration: 300.ms),
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          'INCIDENT DETAILS',
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
                  color: AppColors.primaryPurple.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.primaryPurpleLight,
                    shape: BoxShape.circle,
                    boxShadow: AppColors.innerGlowPurple,
                  ),
                  child: const Icon(Icons.assignment_late_rounded, size: 48, color: AppColors.primaryPurple),
                ),
              ).animate().scale(delay: 50.ms, curve: Curves.easeOutBack, duration: 600.ms),
              
              const SizedBox(height: 24),
              
              const Text(
                'Severe Collision',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDark,
                  letterSpacing: -0.5,
                ),
              ).animate().fade().slideY(begin: 0.1),
              
              const SizedBox(height: 8),
              
              const Text(
                'High Priority Emergency Dispatch',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.emergencyRed,
                  fontWeight: FontWeight.w800,
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
                      'DISPATCH INFORMATION',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textGrey,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    _buildInfoRow(Icons.person_rounded, 'Caller Identity', emergencyData['userName'] ?? 'Unknown'),
                    _buildDivider(),
                    _buildInfoRow(Icons.phone_in_talk_rounded, 'Contact Number', emergencyData['userPhone'] ?? 'N/A'),
                    _buildDivider(),
                    _buildInfoRow(Icons.location_on_rounded, 'Location', 'Lat: ${(emergencyData['location'] as dynamic)?.latitude?.toStringAsFixed(4) ?? 'N/A'}, Lng: ${(emergencyData['location'] as dynamic)?.longitude?.toStringAsFixed(4) ?? 'N/A'}'),
                    _buildDivider(),
                    _buildInfoRow(Icons.bloodtype_rounded, 'Blood Group', emergencyData['bloodGroup'] ?? 'Unknown'),
                    _buildDivider(),
                    _buildInfoRow(Icons.radar_rounded, 'Alert Type', emergencyData['type'] == 'citizens' ? 'Citizen Help Request' : (emergencyData['type'] == 'ambulance' ? 'Ambulance Request' : 'Full Emergency')),
                    
                    const SizedBox(height: 40),
                    
                    // Powerful Gradient Button
                    SizedBox(
                      width: double.infinity,
                      height: 64,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: AppColors.primaryGradient,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryPurple.withOpacity(0.35),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const EnRouteNavigationScreen()));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.near_me_rounded, color: Colors.white, size: 24),
                              SizedBox(width: 12),
                              Text(
                                'NAVIGATE TO SCENE',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5),
                              ),
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

  Widget _buildInfoRow(IconData icon, String title, String data) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primaryPurpleLight,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primaryPurple, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textGrey),
              ),
              const SizedBox(height: 4),
              Text(
                data,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.textDark, height: 1.3),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Divider(color: AppColors.textGrey.withOpacity(0.1), thickness: 1.5),
    );
  }
}
