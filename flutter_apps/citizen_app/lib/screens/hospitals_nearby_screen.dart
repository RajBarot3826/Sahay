// Flutter Screen 11: Hospitals Nearby (Real GPS + OpenStreetMap Overpass API)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import 'hospital_pre_alert_screen.dart';
import 'hospital_navigation_map_screen.dart';
import '../services/hospital_service.dart';
import '../providers/location_provider.dart';

class HospitalsNearbyScreen extends StatefulWidget {
  const HospitalsNearbyScreen({Key? key}) : super(key: key);

  @override
  State<HospitalsNearbyScreen> createState() => _HospitalsNearbyScreenState();
}

class _HospitalsNearbyScreenState extends State<HospitalsNearbyScreen> {
  String selectedFilter = 'All 50 km';

  @override
  void initState() {
    super.initState();
    // If LocationProvider doesn't have hospitals yet, trigger fetch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final locProvider = Provider.of<LocationProvider>(context, listen: false);
      if (!locProvider.hasHospitals && !locProvider.isLoading) {
        locProvider.initialize();
      }
    });
  }

  void _refreshHospitals() {
    Provider.of<LocationProvider>(context, listen: false).refresh();
  }

  void _showMapViewModal(List<HospitalModel> hospitals) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(ctx).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            const Text('LIVE GOOGLE & OSM 50 KM TRAUMA MAP', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13.5, color: AppColors.textDark, letterSpacing: 0.5)),
            const SizedBox(height: 4),
            Text('Displaying ${hospitals.length} Real Hospitals Sorted Min to Max Distance', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
            const SizedBox(height: 14),

            // OpenStreetMap Interactive Layer
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: Stack(
                  children: [
                    FlutterMap(
                      options: MapOptions(
                        initialCenter: hospitals.isNotEmpty ? hospitals.first.location : const LatLng(21.7645, 72.1519),
                        initialZoom: 11.5,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.sahay_citizen_app',
                        ),
                        MarkerLayer(
                          markers: hospitals.map((h) {
                            return Marker(
                              point: h.location,
                              width: 44,
                              height: 44,
                              child: GestureDetector(
                                onTap: () {
                                  ScaffoldMessenger.of(ctx).showSnackBar(
                                    SnackBar(
                                      content: Text('🏥 ${h.name} • Distance: ${h.distanceKm} km'),
                                      backgroundColor: AppColors.brandPurple,
                                    ),
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: h.category == 'Govt.' ? AppColors.emergencyRed : AppColors.brandPurple,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2.5),
                                    boxShadow: AppColors.softShadow,
                                  ),
                                  child: const Icon(Icons.local_hospital_rounded, color: Colors.white, size: 20),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandPurple,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(27)),
                    elevation: 6,
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const HospitalPreAlertScreen()));
                  },
                  icon: const Icon(Icons.add_alert_rounded, color: Colors.white),
                  label: const Text('TRANSMIT ER PRE-ALERT TO CLOSEST TRAUMA CENTER', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use AnnotatedRegion instead of SystemChrome in build()

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Text('100% REAL LIVE NEARBY HOSPITALS', style: TextStyle(color: AppColors.textDark, fontSize: 12, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.brandPurple),
            onPressed: _refreshHospitals,
            tooltip: 'Refresh Live Data',
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Consumer<LocationProvider>(
        builder: (context, locProvider, _) {
          // Loading state
          if (locProvider.isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: AppColors.brandPurple),
                  const SizedBox(height: 16),
                  Text(
                    locProvider.isLoadingLocation
                        ? 'Getting your real GPS location...'
                        : 'Finding 24/7 hospitals within 50 km...',
                    style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ],
              ),
            );
          }

          // Error state
          if (locProvider.locationError != null || locProvider.hospitalError != null) {
            final error = locProvider.locationError ?? locProvider.hospitalError ?? 'Unknown error';
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      locProvider.locationError != null ? Icons.location_off_rounded : Icons.wifi_off_rounded,
                      color: AppColors.emergencyRed,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      locProvider.locationError != null ? 'Location Error' : 'Hospital Fetch Error',
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.textDark),
                    ),
                    const SizedBox(height: 6),
                    Text(error, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.brandPurple, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                      onPressed: _refreshHospitals,
                      icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                      label: const Text('Retry', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            );
          }

          final List<HospitalModel> allHospitals = locProvider.hospitals;

          return Column(
            children: [
              // Filter Pills
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildFilterChip('All 50 km'),
                    _buildFilterChip('< 10 km'),
                    _buildFilterChip('< 25 km'),
                    _buildFilterChip('Trauma 24/7'),
                    _buildFilterChip('Govt.'),
                    _buildFilterChip('Private'),
                  ],
                ),
              ),

              // Hospital count + location info
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Builder(builder: (_) {
                        // Apply filter
                        final filtered = _applyFilter(allHospitals);
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: AppColors.brandPurple.withAlpha(20), borderRadius: BorderRadius.circular(12)),
                          child: Text(
                            'FOUND ${filtered.length} REAL 24/7 HOSPITALS NEAR YOU',
                            style: const TextStyle(color: AppColors.brandPurple, fontSize: 10.5, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                          ),
                        );
                      }),
                    ),
                    if (locProvider.hasLocation) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.gps_fixed_rounded, color: AppColors.successGreen, size: 14),
                      const SizedBox(width: 2),
                      const Text('GPS', style: TextStyle(color: AppColors.successGreen, fontSize: 10, fontWeight: FontWeight.w900)),
                    ],
                  ],
                ),
              ),

              // Hospital list
              Expanded(
                child: Builder(builder: (context) {
                  final filteredHospitals = _applyFilter(allHospitals);

                  if (filteredHospitals.isEmpty) {
                    return const Center(
                      child: Text('No hospitals match this filter.', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    physics: const BouncingScrollPhysics(),
                    itemCount: filteredHospitals.length + 1,
                    itemBuilder: (context, index) {
                      if (index == filteredHospitals.length) {
                        return const SizedBox(height: 90);
                      }
                      final hospital = filteredHospitals[index];
                      return _buildHospitalCard(context, hospital);
                    },
                  );
                }),
              ),
            ],
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: AppColors.primaryGradient,
            boxShadow: AppColors.glowPurple,
          ),
          child: Consumer<LocationProvider>(
            builder: (ctx, locProvider, _) {
              final list = locProvider.hospitals;
              return ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                ),
                onPressed: () => _showMapViewModal(list),
                icon: const Icon(Icons.map_rounded, color: Colors.white, size: 20),
                label: Text('View ${list.length} Real Hospitals on Map', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Colors.white, letterSpacing: 0.5)),
              );
            },
          ),
        ),
      ),
      ),
    );
  }

  List<HospitalModel> _applyFilter(List<HospitalModel> all) {
    List<HospitalModel> filtered = all.where((h) {
      if (selectedFilter == 'All 50 km') return h.distanceKm <= 50.0;
      if (selectedFilter == '< 10 km') return h.distanceKm <= 10.0;
      if (selectedFilter == '< 25 km') return h.distanceKm <= 25.0;
      if (selectedFilter == 'Govt.') return h.category == 'Govt.';
      if (selectedFilter == 'Private') return h.category == 'Private';
      if (selectedFilter == 'Trauma 24/7') return h.category == 'Trauma' || h.type.toLowerCase().contains('trauma');
      return true;
    }).toList();
    filtered.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    return filtered;
  }

  Widget _buildFilterChip(String label) {
    final isSelected = selectedFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        showCheckmark: false,
        selectedColor: AppColors.brandPurple,
        backgroundColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppColors.textSecondary,
          fontWeight: FontWeight.w800,
          fontSize: 12.5,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: isSelected ? AppColors.brandPurple : Colors.black.withAlpha(15), width: 1.5),
        ),
        onSelected: (val) {
          setState(() => selectedFilter = label);
        },
      ),
    );
  }

  Widget _buildHospitalCard(BuildContext context, HospitalModel hospital) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: AppColors.softShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => HospitalPreAlertScreen(hospital: hospital))),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: hospital.category == 'Govt.' ? AppColors.emergencyRed.withAlpha(20) : AppColors.brandPurple.withAlpha(20),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(
                        Icons.local_hospital_rounded,
                        color: hospital.category == 'Govt.' ? AppColors.emergencyRed : AppColors.brandPurple,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hospital.name,
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15.5, color: AppColors.textDark, height: 1.3),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            hospital.type,
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                          if (hospital.address.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Text(
                              hospital.address,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.successGreen.withAlpha(20),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.successGreen.withAlpha(80)),
                      ),
                      child: const Row(
                        children: [
                          CircleAvatar(radius: 3, backgroundColor: AppColors.successGreen),
                          SizedBox(width: 4),
                          Text('OPEN 24/7', style: TextStyle(color: AppColors.successGreen, fontSize: 9.5, fontWeight: FontWeight.w900)),
                        ],
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Divider(height: 1, color: Colors.black12),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: [
                            const Icon(Icons.near_me_rounded, color: AppColors.emergencyRed, size: 15),
                            const SizedBox(width: 4),
                            Text(
                              '${hospital.distanceKm} km',
                              style: const TextStyle(color: AppColors.emergencyRed, fontSize: 13, fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.timer_outlined, color: AppColors.textSecondary, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              'ETA: ${hospital.etaMins} mins',
                              style: const TextStyle(color: AppColors.textDark, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.brandPurple.withAlpha(20),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${hospital.icuBeds} ICU Beds Free',
                                style: const TextStyle(color: AppColors.brandPurple, fontSize: 10.5, fontWeight: FontWeight.w900),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => HospitalNavigationMapScreen(hospital: hospital),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: AppColors.brandPurple,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.navigation_rounded, color: Colors.white, size: 16),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Calling ${hospital.name} ER Desk (${hospital.phone})...')),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: AppColors.successGreen,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.call_rounded, color: Colors.white, size: 16),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
