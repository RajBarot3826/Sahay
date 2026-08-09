// Flutter Screen 3: Police Officer Dashboard (Matching UI Mockup 3)
import 'package:flutter/material.dart';
import 'field_qr_scanner_screen.dart';
import 'stolen_vehicle_screen.dart';
import 'edar_report_screen.dart';
import 'edar_incident_report_screen.dart';
import 'evidence_capture_screen.dart';
import 'checkpoint_management_screen.dart';
import 'wanted_person_database_screen.dart';
import 'pcr_calls_queue_screen.dart';
import 'police_panic_screen.dart';
import 'police_dashboard.dart';
import '../constants/app_colors.dart';

class PoliceDashboardScreen extends StatelessWidget {
  const PoliceDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        title: const Text('Police Control Response'),
        backgroundColor: AppColors.navyDark,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Officer Badge Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Inspector Raj Singh 👋', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text('Badge: RJPS-1245 • Vehicle: RJ14 PC 1234', style: TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
                const CircleAvatar(
                  backgroundColor: Color(0xFFA855F7),
                  child: Icon(Icons.security, color: Colors.white),
                )
              ],
            ),
            const SizedBox(height: 16),

            // Performance Metrics Row
            Row(
              children: [
                _buildPoliceMetric('32', 'Incidents Handled', Colors.blue),
                const SizedBox(width: 8),
                _buildPoliceMetric('78', 'People Helped', Colors.green),
                const SizedBox(width: 8),
                _buildPoliceMetric('06:24', 'Avg Response', Colors.amber),
              ],
            ),
            const SizedBox(height: 20),

            // Navigation Grid to Dedicated Screens
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 2.0,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              children: [
                _buildActionTile(Icons.assignment, 'EDAR Incident Report', Colors.orange, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const EdarIncidentReportScreen()));
                }),
                _buildActionTile(Icons.camera_alt, 'Evidence Capture', Colors.blue, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const EvidenceCaptureScreen()));
                }),
                _buildActionTile(Icons.security, 'Checkpoint Management', Colors.green, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const CheckpointManagementScreen()));
                }),
                _buildActionTile(Icons.person_search, 'Wanted Person Database', Colors.purple, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const WantedPersonDatabaseScreen()));
                }),
                _buildActionTile(Icons.call, 'PCR Calls Queue', Colors.teal, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const PcrCallsQueueScreen()));
                }),
                _buildActionTile(Icons.qr_code_scanner, 'Field QR Scanner', const Color(0xFFA855F7), () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const FieldQrScannerScreen()));
                }),
                _buildActionTile(Icons.directions_car, 'Stolen Vehicle', Colors.red, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const StolenVehicleScreen()));
                }),
                _buildActionTile(Icons.article, 'EDAR Report', Colors.amber, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const EdarReportScreen()));
                }),
                _buildActionTile(Icons.warning, 'Panic Button', Colors.redAccent, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const PolicePanicScreen()));
                }),
                _buildActionTile(Icons.map, 'PCR Command Center', Colors.blueAccent, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const PoliceDashboard()));
                }),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPoliceMetric(String val, String label, Color color) {
    return Expanded(
      child: Card(
        color: AppColors.navyDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Text(val, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: color)),
              const SizedBox(height: 2),
              Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionTile(IconData icon, String title, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.navyDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white12),
        ),
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 8),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white))),
          ],
        ),
      ),
    );
  }
}
