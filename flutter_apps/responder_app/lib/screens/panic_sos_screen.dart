import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../providers/responder_state.dart';

class PanicSOSScreen extends StatefulWidget {
  const PanicSOSScreen({super.key});

  @override
  State<PanicSOSScreen> createState() => _PanicSOSScreenState();
}

class _PanicSOSScreenState extends State<PanicSOSScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _sosTriggered = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _triggerSOS() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm SOS'),
        content: const Text('Are you sure you want to trigger a panic alert?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Trigger', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _sosTriggered = true;
    });

    try {
      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      final state = Provider.of<ResponderState>(context, listen: false);

      await FirebaseFirestore.instance.collection('panic_alerts').add({
        'responderPhone': state.phone,
        'responderName': state.driverName,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('SOS Sent'),
            content: const Text('SOS Signal Broadcasted to EMRI Hub & Nearby Units!'),
            actions: [
              TextButton(onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Close screen
              }, child: const Text('OK')),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _sosTriggered = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1B4B), // Deep dark background for high contrast
      body: SafeArea(
        child: Stack(
          children: [
            // Close Button
            Positioned(
              top: 20,
              left: 20,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close_rounded, size: 24, color: Colors.white),
                ),
              ),
            ),
            
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'EMERGENCY SOS',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 4.0,
                    ),
                  ).animate().fade().slideY(begin: -0.2),
                  
                  const SizedBox(height: 12),
                  
                  const Text(
                    'Tap the button below to instantly alert\nthe central dispatch hub and all nearby units.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                    ),
                  ).animate().fade(delay: 100.ms),
                  
                  const SizedBox(height: 60),
                  
                  // Massive Pulsing SOS Button
                  GestureDetector(
                    onTap: _sosTriggered ? null : _triggerSOS,
                    child: AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _sosTriggered ? 1.0 : _pulseAnimation.value,
                          child: Container(
                            width: 280,
                            height: 280,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  AppColors.emergencyRed,
                                  AppColors.emergencyRedDark,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.emergencyRed.withOpacity(_sosTriggered ? 0.2 : 0.6),
                                  blurRadius: _sosTriggered ? 20 : 80,
                                  spreadRadius: _sosTriggered ? 0 : 20,
                                ),
                              ],
                            ),
                            child: Center(
                              child: _sosTriggered
                                  ? const Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.wifi_tethering_rounded, color: Colors.white, size: 64),
                                        SizedBox(height: 16),
                                        Text('BROADCASTING...', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 2.0)),
                                      ],
                                    ).animate().fade().scale()
                                  : const Text(
                                      'SOS',
                                      style: TextStyle(
                                        fontSize: 72,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                        letterSpacing: 2.0,
                                      ),
                                    ),
                            ),
                          ),
                        );
                      },
                    ),
                  ).animate().scale(curve: Curves.easeOutBack, duration: 600.ms, delay: 200.ms),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
