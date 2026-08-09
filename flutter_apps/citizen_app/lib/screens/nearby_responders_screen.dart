// Flutter Screen 8: Nearby Responders — Real Firestore Data
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../constants/app_colors.dart';
import '../providers/emergency_provider.dart';
import '../providers/location_provider.dart';

class NearbyRespondersScreen extends StatefulWidget {
  const NearbyRespondersScreen({Key? key}) : super(key: key);

  @override
  State<NearbyRespondersScreen> createState() => _NearbyRespondersScreenState();
}

class _NearbyRespondersScreenState extends State<NearbyRespondersScreen> with SingleTickerProviderStateMixin {
  late AnimationController _radarController;

  @override
  void initState() {
    super.initState();
    _radarController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _radarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    return Consumer2<EmergencyProvider, LocationProvider>(
      builder: (context, emergency, locProvider, _) {
        final bool isActive = emergency.isEmergencyActive;
        final responders = emergency.acceptedResponders;

        // Real GPS coordinates
        final double userLat = emergency.userPosition?.latitude ?? locProvider.latitude;
        final double userLng = emergency.userPosition?.longitude ?? locProvider.longitude;
        final LatLng userLatLng = LatLng(
          userLat != 0 ? userLat : 21.7645,
          userLng != 0 ? userLng : 72.1519,
        );

        return Scaffold(
          backgroundColor: AppColors.bgLight,
          appBar: AppBar(
            title: const Text('NEARBY RESPONDERS', style: TextStyle(color: AppColors.textDark, fontSize: 12, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: AppColors.softShadow),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textDark, size: 18),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                // Map with radar animation
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      FlutterMap(
                        options: MapOptions(initialCenter: userLatLng, initialZoom: 14.0),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.example.sahay_citizen_app',
                          ),
                          MarkerLayer(
                            markers: [
                              // User marker
                              Marker(
                                point: userLatLng,
                                width: 50,
                                height: 50,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isActive ? AppColors.emergencyRed : AppColors.brandPurple,
                                    shape: BoxShape.circle,
                                    boxShadow: isActive ? AppColors.glowRed : AppColors.glowPurple,
                                  ),
                                  child: const Icon(Icons.person_pin_circle_rounded, color: Colors.white, size: 28),
                                ),
                              ),
                              // Real responder markers
                              ...responders.map((r) {
                                final rLat = r['latitude'] as double? ?? 0;
                                final rLng = r['longitude'] as double? ?? 0;
                                if (rLat == 0 && rLng == 0) return null;
                                return Marker(
                                  point: LatLng(rLat, rLng),
                                  width: 40,
                                  height: 40,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.successGreen,
                                      shape: BoxShape.circle,
                                      boxShadow: AppColors.softShadow,
                                    ),
                                    child: const Icon(Icons.medical_services_rounded, color: Colors.white, size: 20),
                                  ),
                                );
                              }).whereType<Marker>(),
                            ],
                          ),
                        ],
                      ),

                      // Radar pulse
                      AnimatedBuilder(
                        animation: _radarController,
                        builder: (context, child) {
                          return Container(
                            width: 160 + (80 * _radarController.value),
                            height: 160 + (80 * _radarController.value),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: (isActive ? AppColors.emergencyRed : AppColors.brandPurple).withAlpha((20 * (1 - _radarController.value)).toInt()),
                              border: Border.all(
                                color: (isActive ? AppColors.emergencyRed : AppColors.brandPurple).withAlpha((80 * (1 - _radarController.value)).toInt()),
                                width: 2,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // Bottom panel
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, spreadRadius: 5)],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40, height: 4,
                          decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isActive ? '🚨 Responders Alerted' : 'Responder Network',
                                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 19, color: AppColors.textDark),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isActive
                                      ? '${responders.length} responder(s) accepted • Radius: ${emergency.currentRadiusKm.toStringAsFixed(0)} km'
                                      : 'Trigger SOS to alert nearby responders',
                                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: (isActive ? AppColors.emergencyRed : AppColors.brandPurple).withAlpha(20),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.radar_rounded, color: isActive ? AppColors.emergencyRed : AppColors.brandPurple, size: 15),
                                const SizedBox(width: 4),
                                Text(
                                  isActive ? 'DISPATCHED' : 'STANDBY',
                                  style: TextStyle(color: isActive ? AppColors.emergencyRed : AppColors.brandPurple, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Responder list
                      if (responders.isNotEmpty)
                        ...responders.map((r) => _buildResponderTile(
                          r['name'] ?? 'Responder',
                          '${r['distanceKm'] ?? '?'} km away • ETA ~${r['etaMins'] ?? '?'} mins',
                          true,
                        ))
                      else if (isActive)
                        _buildResponderTile('Searching...', 'Looking for nearby responders in ${emergency.currentRadiusKm.toStringAsFixed(0)} km radius', false)
                      else
                        _buildResponderTile('No Active SOS', 'Press SOS on the dashboard to alert responders', false),

                      const SizedBox(height: 16),

                      // Trigger / Cancel button
                      if (!isActive)
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.emergencyRed,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(27)),
                              elevation: 6,
                            ),
                            onPressed: () {
                              emergency.startCountdown();
                              Navigator.pop(context);
                              // Goes back to dashboard where countdown overlay will show
                            },
                            icon: const Icon(Icons.sos_rounded, color: Colors.white, size: 22),
                            label: const Text('TRIGGER SOS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Colors.white)),
                          ),
                        )
                      else
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  side: BorderSide(color: Colors.grey.withAlpha(80)),
                                ),
                                onPressed: () async {
                                  await emergency.cancelSOS();
                                },
                                child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.successGreen,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                ),
                                onPressed: () => Navigator.pushNamed(context, '/live_tracking'),
                                child: const Text('Track Live', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Colors.white)),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildResponderTile(String name, String detail, bool isEnRoute) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isEnRoute ? AppColors.emergencyRed.withAlpha(10) : AppColors.bgLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isEnRoute ? AppColors.emergencyRed.withAlpha(80) : Colors.black.withAlpha(10)),
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: isEnRoute ? AppColors.emergencyRed.withAlpha(20) : AppColors.brandPurpleLight,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isEnRoute ? Icons.medical_services_rounded : Icons.person_rounded,
              color: isEnRoute ? AppColors.emergencyRed : AppColors.brandPurple,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textDark)),
                const SizedBox(height: 2),
                Text(detail, style: TextStyle(color: isEnRoute ? AppColors.emergencyRed : AppColors.textSecondary, fontSize: 11.5, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: (isEnRoute ? AppColors.emergencyRed : AppColors.successGreen).withAlpha(20),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              isEnRoute ? 'En Route' : 'Standby',
              style: TextStyle(color: isEnRoute ? AppColors.emergencyRed : AppColors.successGreen, fontSize: 10, fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}
