// Flutter Main Entry Point for Sahay Mobile Application
import 'package:flutter/material.dart';
import 'services/crash_detection_service.dart';

void main() {
  runApp(const SahayApp());
}

class SahayApp extends StatelessWidget {
  const SahayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sahay Mobile',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        primaryColor: const Color(0xFFFF2A4B),
        scaffoldBackgroundColor: const Color(0xFF070A12),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFF2A4B),
          secondary: Color(0xFF38BDF8),
        ),
      ),
      home: const SahayDashboardScreen(),
    );
  }
}

class SahayDashboardScreen extends StatefulWidget {
  const SahayDashboardScreen({super.key});

  @override
  State<SahayDashboardScreen> createState() => _SahayDashboardScreenState();
}

class _SahayDashboardScreenState extends State<SahayDashboardScreen> {
  bool isCrashDetectionActive = true;
  final CrashDetectionService _crashService = CrashDetectionService();

  @override
  void initState() {
    super.initState();
    _startCrashService();
  }

  void _startCrashService() {
    _crashService.startSensorMonitoring(
      onCrashDetected: (gForce) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Crash Detected! G-Force: ${gForce.toStringAsFixed(2)}'),
            backgroundColor: Colors.red,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _crashService.stopMonitoring();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sahay (સહાય) Driver & Responder'),
        backgroundColor: const Color(0xFF0F172A),
        actions: [
          IconButton(
            icon: const Icon(Icons.shield),
            onPressed: () {},
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Driver Automatic Crash Sensor Status
              Card(
                color: const Color(0xFF0F172A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFF38BDF8), width: 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.sensors, color: Color(0xFF10B981), size: 36),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Automatic Crash Sensor Active',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              'Uses Accelerometer & Gyroscope (> 4G Force Detection)',
                              style: TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: isCrashDetectionActive,
                        onChanged: (val) {
                          setState(() => isCrashDetectionActive = val);
                          if (val) {
                            _startCrashService();
                          } else {
                            _crashService.stopMonitoring();
                          }
                        },
                        activeColor: const Color(0xFF10B981),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Champion Corridor Dispatch Alert Box
              const Text(
                'Sahay Highway Corridor Champion Alerts',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Card(
                color: const Color(0xFF1E293B),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFFF2A4B),
                    child: Icon(Icons.warning, color: Colors.white),
                  ),
                  title: const Text('CRASH ALERT: 550m Away (NH-8E Km 14)'),
                  subtitle: const Text('Bystander SOS Triggered • Pressure Bandage Needed'),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
                    onPressed: () {},
                    child: const Text('ACCEPT'),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
