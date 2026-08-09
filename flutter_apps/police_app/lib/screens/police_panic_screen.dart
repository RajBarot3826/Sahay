// Flutter Screen 24: Police Officer Panic Button (Matching UI Mockup 3)
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class PolicePanicScreen extends StatelessWidget {
  const PolicePanicScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        title: const Text('Emergency Officer Panic'),
        backgroundColor: AppColors.navyDark,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.emergencyRed,
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(36),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Officer Tactical Backup Signal Sent to Police Control Room!')),
                );
              },
              child: const Text('SOS\nPANIC', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ),
            const SizedBox(height: 20),
            const Text('Press and hold for 3 seconds to request armed/PCR backup', style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
