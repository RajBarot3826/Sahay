import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers/responder_state.dart';

class VehicleStatusScreen extends StatelessWidget {
  const VehicleStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<ResponderState>(context);
    final unitName = state.ambulanceNumber.isNotEmpty ? state.ambulanceNumber : 'Unknown Unit';
    final vType = state.vehicleType.isNotEmpty ? state.vehicleType : 'ALS';
    final titleStr = '$unitName - $vType';

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: AppColors.softShadow),
                        child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.textDark),
                      ),
                    ).animate().scale(curve: Curves.easeOutBack, duration: 300.ms),
                    const Expanded(
                      child: Center(
                        child: Text(
                          'VEHICLE DIAGNOSTICS',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.primaryPurple, letterSpacing: 2.0),
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
                decoration: BoxDecoration(color: AppColors.primaryPurple.withOpacity(0.05), shape: BoxShape.circle),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(color: AppColors.primaryPurpleLight, shape: BoxShape.circle, boxShadow: AppColors.innerGlowPurple),
                  child: const Icon(Icons.directions_car_filled_rounded, size: 48, color: AppColors.primaryPurple),
                ),
              ).animate().scale(delay: 50.ms, curve: Curves.easeOutBack, duration: 600.ms),
              
              const SizedBox(height: 24),
              
              Text(titleStr, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.textDark, letterSpacing: -0.5)).animate().fade().slideY(begin: 0.1),
              const SizedBox(height: 8),
              const Text('All Systems Operational', style: TextStyle(fontSize: 16, color: AppColors.successGreen, fontWeight: FontWeight.w800)).animate().fade(delay: 100.ms).slideY(begin: 0.1),
              
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
                    const Text('CRITICAL INVENTORY', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.textGrey, letterSpacing: 1.5)),
                    const SizedBox(height: 24),
                    
                    _buildIndicatorRow(Icons.local_gas_station_rounded, 'Fuel Level', '85%', AppColors.successGreen),
                    _buildDivider(),
                    _buildIndicatorRow(Icons.air_rounded, 'Oxygen Tanks', 'Full (2/2)', AppColors.successGreen),
                    _buildDivider(),
                    _buildIndicatorRow(Icons.medical_services_rounded, 'Trauma Kit', 'Fully Stocked', AppColors.successGreen),
                    _buildDivider(),
                    _buildIndicatorRow(Icons.build_rounded, 'Engine Health', 'Requires Service Soon', AppColors.warningAmber),
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

  Widget _buildIndicatorRow(IconData icon, String title, String data, Color statusColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: statusColor.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: statusColor, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textGrey)),
              const SizedBox(height: 4),
              Text(data, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: statusColor, height: 1.3)),
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
