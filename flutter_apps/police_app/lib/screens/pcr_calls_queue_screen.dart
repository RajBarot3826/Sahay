import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_colors.dart';

class PcrCallsQueueScreen extends StatelessWidget {
  const PcrCallsQueueScreen({super.key});

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
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: AppColors.navyDark, shape: BoxShape.circle, border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.3))),
                      child: const Icon(Icons.menu_rounded, size: 20, color: Colors.white),
                    ).animate().scale(curve: Curves.easeOutBack, duration: 400.ms),
                    const Expanded(
                      child: Center(
                        child: Text(
                          'DISPATCH QUEUE',
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
                child: const Text('ACTIVE\nALERTS', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white, height: 1.1, letterSpacing: -0.5))
                  .animate().fade().slideX(begin: -0.1),
              ),
              
              const SizedBox(height: 32),
              
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: 3,
                itemBuilder: (context, index) {
                  return _buildQueueCard(context, index);
                },
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQueueCard(BuildContext context, int index) {
    final bool isCritical = index == 0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: AppColors.premiumCardShadow,
        border: Border.all(color: isCritical ? AppColors.emergencyRed : Colors.transparent, width: 2),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isCritical ? AppColors.emergencyRedBg : AppColors.warningAmberLight,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(isCritical ? Icons.local_fire_department_rounded : Icons.car_crash_rounded, 
                              color: isCritical ? AppColors.emergencyRed : AppColors.warningAmber, size: 28),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isCritical ? AppColors.emergencyRed : AppColors.warningAmber,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(isCritical ? 'CRITICAL' : 'HIGH', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.0)),
                          ),
                          Text(isCritical ? '2m ago' : '12m ago', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textGrey)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(isCritical ? 'Armed Robbery in Progress' : 'Multi-Vehicle Collision', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textDark, letterSpacing: -0.5)),
                      const SizedBox(height: 6),
                      Text(isCritical ? 'Sector 9, Downtown Plaza' : 'Highway 44, Mile Marker 12', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textGrey)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              color: AppColors.bgColor.withValues(alpha: 0.02),
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
              border: Border(top: BorderSide(color: AppColors.textGrey.withValues(alpha: 0.1))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Locating incident on live map...')));
                    },
                    icon: const Icon(Icons.location_on_rounded, color: AppColors.primaryBlue),
                    label: const Text('VIEW ON MAP', style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.0)),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      backgroundColor: AppColors.primaryBlueLight.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Unit Dispatched. ETA 4 mins.')));
                    },
                    icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
                    label: const Text('RESPOND', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.0)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isCritical ? AppColors.emergencyRed : AppColors.primaryBlue,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fade(delay: (200 + (index * 100)).ms, duration: 600.ms).slideY(begin: 0.1);
  }
}
