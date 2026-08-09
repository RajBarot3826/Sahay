// Flutter Screen 7: Live Tracking — Real GPS + Firestore Responder Markers
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../constants/app_colors.dart';
import '../providers/emergency_provider.dart';
import '../providers/location_provider.dart';

class LiveTrackingScreen extends StatefulWidget {
  const LiveTrackingScreen({Key? key}) : super(key: key);

  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    return Consumer2<EmergencyProvider, LocationProvider>(
      builder: (context, emergency, locProvider, _) {
        final bool isActive = emergency.isEmergencyActive;
        final bool hasResponders = emergency.acceptedResponders.isNotEmpty;

        // Use real GPS or fallback
        final double userLat = emergency.userPosition?.latitude ?? locProvider.latitude;
        final double userLng = emergency.userPosition?.longitude ?? locProvider.longitude;
        final LatLng userLatLng = LatLng(
          userLat != 0 ? userLat : 21.7645,
          userLng != 0 ? userLng : 72.1519,
        );

        return Scaffold(
          backgroundColor: AppColors.bgLight,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            title: const Text('LIVE TRACKING', style: TextStyle(color: AppColors.textDark, fontSize: 12, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
            backgroundColor: Colors.white.withAlpha(200),
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
          body: Stack(
            children: [
              // Live Map
              SizedBox(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: userLatLng,
                    initialZoom: 14.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.sahay_citizen_app',
                    ),
                    MarkerLayer(
                      markers: [
                        // User's real GPS position
                        Marker(
                          point: userLatLng,
                          width: 50,
                          height: 50,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.brandPurple,
                              shape: BoxShape.circle,
                              boxShadow: AppColors.glowPurple,
                            ),
                            child: const Icon(Icons.person_pin_circle_rounded, color: Colors.white, size: 28),
                          ),
                        ),
                        // Accepted responder markers from Firestore
                        ...emergency.acceptedResponders.map((r) {
                          final rLat = r['latitude'] as double? ?? 0;
                          final rLng = r['longitude'] as double? ?? 0;
                          if (rLat == 0 && rLng == 0) return null;
                          return Marker(
                            point: LatLng(rLat, rLng),
                            width: 44,
                            height: 44,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.emergencyRed,
                                shape: BoxShape.circle,
                                boxShadow: AppColors.glowRed,
                              ),
                              child: const Icon(Icons.medical_services_rounded, color: Colors.white, size: 22),
                            ),
                          );
                        }).whereType<Marker>(),
                      ],
                    ),
                  ],
                ),
              ),

              // Top Status Banner
              Positioned(
                top: 100,
                left: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: AppColors.softShadow,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isActive ? AppColors.emergencyRed.withAlpha(20) : Colors.grey.withAlpha(40),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          isActive ? 'ACTIVE' : 'STANDBY',
                          style: TextStyle(
                            color: isActive ? AppColors.emergencyRed : AppColors.textSecondary,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              emergency.statusText,
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textDark),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isActive
                                  ? '${emergency.acceptedCount} responder(s) • ETA: ${emergency.eta}'
                                  : 'Trigger SOS to request help',
                              style: TextStyle(
                                color: isActive ? AppColors.emergencyRed : AppColors.textSecondary,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (locProvider.hasLocation)
                        const Icon(Icons.gps_fixed_rounded, color: AppColors.successGreen, size: 16),
                    ],
                  ),
                ),
              ),

              // Bottom Sheet
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                    boxShadow: [BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 20, offset: const Offset(0, -5))],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40, height: 4,
                          decoration: BoxDecoration(color: Colors.grey.withAlpha(50), borderRadius: BorderRadius.circular(2)),
                        ),
                      ),
                      const SizedBox(height: 16),

                      if (!isActive) ...[
                        // Inactive state
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(color: Colors.grey.withAlpha(30), shape: BoxShape.circle),
                              child: const Icon(Icons.location_off_rounded, color: AppColors.textSecondary, size: 28),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('No Dispatch Active', style: TextStyle(color: AppColors.textDark, fontSize: 17, fontWeight: FontWeight.w900)),
                                  SizedBox(height: 4),
                                  Text('Live tracking activates once responders accept your SOS.', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.3)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ] else ...[
                        // Active — show accepted responders
                        const Text('DISPATCH DETAILS', style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                        const SizedBox(height: 12),

                        if (hasResponders)
                          ...emergency.acceptedResponders.map((r) => _buildResponderTile(r))
                        else
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(color: AppColors.emergencyRed.withAlpha(20), borderRadius: BorderRadius.circular(16)),
                                child: const Icon(Icons.search_rounded, color: AppColors.emergencyRed, size: 28),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Searching...', style: TextStyle(color: AppColors.textDark, fontSize: 17, fontWeight: FontWeight.w900)),
                                    Text('Radius: ${emergency.currentRadiusKm.toStringAsFixed(0)} km', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                                  ],
                                ),
                              ),
                            ],
                          ),

                        const SizedBox(height: 16),
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
                                  if (context.mounted) Navigator.pop(context);
                                },
                                child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  gradient: AppColors.primaryGradient,
                                ),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  ),
                                  onPressed: () {
                                    // Center map on user
                                    _mapController.move(userLatLng, 15.0);
                                  },
                                  child: const Text('Center Map', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildResponderTile(Map<String, dynamic> responder) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.emergencyRed.withAlpha(10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.emergencyRed.withAlpha(60)),
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: AppColors.emergencyRed.withAlpha(20), shape: BoxShape.circle),
            child: const Icon(Icons.medical_services_rounded, color: AppColors.emergencyRed, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(responder['name'] ?? 'Responder', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textDark)),
                Text(
                  '${responder['distanceKm'] ?? '?'} km • ETA ~${responder['etaMins'] ?? '?'} mins',
                  style: const TextStyle(color: AppColors.emergencyRed, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: AppColors.emergencyRed.withAlpha(20), borderRadius: BorderRadius.circular(12)),
            child: const Text('En Route', style: TextStyle(color: AppColors.emergencyRed, fontSize: 10, fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
}
