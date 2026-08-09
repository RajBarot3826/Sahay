import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../constants/app_colors.dart';
import '../providers/responder_state.dart';
import 'in_transit_screen.dart';

class HospitalSelectionScreen extends StatefulWidget {
  const HospitalSelectionScreen({super.key});

  @override
  State<HospitalSelectionScreen> createState() => _HospitalSelectionScreenState();
}

class _HospitalSelectionScreenState extends State<HospitalSelectionScreen> {
  List<Map<String, dynamic>> _hospitals = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchHospitals();
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    var p = 0.017453292519943295;
    var c = math.cos;
    var a = 0.5 - c((lat2 - lat1) * p)/2 + 
            c(lat1 * p) * c(lat2 * p) * 
            (1 - c((lon2 - lon1) * p))/2;
    return 12742 * math.asin(math.sqrt(a));
  }

  Future<void> _fetchHospitals() async {
    try {
      final state = Provider.of<ResponderState>(context, listen: false);
      final lat = state.currentLat;
      final lng = state.currentLng;

      if (lat == 0.0 && lng == 0.0) {
        setState(() {
          _error = 'Location not available';
          _isLoading = false;
        });
        return;
      }

      final url = 'https://overpass-api.de/api/interpreter?data=[out:json];node[amenity=hospital](around:50000,$lat,$lng);out body;';
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 15));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final elements = data['elements'] as List;
        
        List<Map<String, dynamic>> parsedHospitals = [];
        for (var el in elements) {
          if (el['tags'] != null && el['tags']['name'] != null) {
            double hLat = el['lat'];
            double hLng = el['lon'];
            double dist = _calculateDistance(lat, lng, hLat, hLng);
            
            parsedHospitals.add({
              'id': el['id'].toString(),
              'name': el['tags']['name'],
              'distance': dist,
              'eta': (dist / 30 * 60).ceil(), // rough ETA 30km/h
              'lat': hLat,
              'lng': hLng,
            });
          }
        }
        
        parsedHospitals.sort((a, b) => (a['distance'] as double).compareTo(b['distance'] as double));
        
        if (mounted) {
          setState(() {
            _hospitals = parsedHospitals.take(5).toList();
            _isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to fetch hospitals');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error fetching hospitals';
          _isLoading = false;
        });
      }
    }
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
                          'DESTINATION HUB',
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
                  child: const Icon(Icons.local_hospital_rounded, size: 48, color: AppColors.primaryPurple),
                ),
              ).animate().scale(delay: 50.ms, curve: Curves.easeOutBack, duration: 600.ms),
              
              const SizedBox(height: 24),
              
              const Text(
                'Select Hospital',
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
                  'Choose the nearest facility equipped for severe trauma.',
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
              
              // Hospital List
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: _isLoading 
                    ? const Center(child: CircularProgressIndicator(color: AppColors.primaryPurple))
                    : _error.isNotEmpty 
                        ? Center(child: Text(_error, style: const TextStyle(color: AppColors.emergencyRed)))
                        : _hospitals.isEmpty
                            ? const Center(child: Text('No hospitals found nearby.', style: TextStyle(color: AppColors.textGrey)))
                            : Column(
                                children: _hospitals.asMap().entries.map((entry) {
                                  int idx = entry.key;
                                  var hosp = entry.value;
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 16.0),
                                    child: _buildHospitalCard(
                                      context, 
                                      hosp,
                                      idx == 0,
                                    ),
                                  );
                                }).toList(),
                              ),
              ).animate().fade(delay: 200.ms).slideY(begin: 0.1),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHospitalCard(BuildContext context, Map<String, dynamic> hosp, bool recommended) {
    return GestureDetector(
      onTap: () {
        final state = Provider.of<ResponderState>(context, listen: false);
        state.setSelectedHospital(hosp);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const InTransitScreen()));
      },
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: recommended ? AppColors.primaryPurple : Colors.transparent, width: 2),
          boxShadow: recommended ? AppColors.premiumCardShadow : AppColors.softShadow,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: recommended ? AppColors.primaryPurple : AppColors.bgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.add_business_rounded, color: recommended ? Colors.white : AppColors.textGrey, size: 28),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          hosp['name'],
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                            color: recommended ? AppColors.primaryPurple : AppColors.textDark,
                          ),
                        ),
                      ),
                      if (recommended)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryPurpleLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('RECOMMENDED', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: AppColors.primaryPurple)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Hospital',
                    style: const TextStyle(color: AppColors.textGrey, fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.route_rounded, size: 16, color: AppColors.textGrey),
                      const SizedBox(width: 4),
                      Text('${(hosp['distance'] as double).toStringAsFixed(1)} km • ${hosp['eta']} mins', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.textDark)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
