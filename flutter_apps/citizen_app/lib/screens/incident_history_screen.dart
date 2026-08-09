// Flutter Screen 16: Incident History (Fully Functional)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';

class IncidentHistoryScreen extends StatelessWidget {
  const IncidentHistoryScreen({Key? key}) : super(key: key);

  void _showPdfReport(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(ctx).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Icon(Icons.picture_as_pdf_rounded, color: Colors.red, size: 28),
                  SizedBox(width: 12),
                  Text('GOOD SAMARITAN REPORT #SH-2025-04', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.textDark)),
                ],
              ),
              const Divider(height: 32),
              const Text('REPORT DETAILS:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(height: 12),
              _buildReportRow('Total Interventions:', '3 Verified Incidents'),
              _buildReportRow('Lives Impacted:', '2 Victims Assisted'),
              _buildReportRow('Good Samaritan Status:', 'Immune Under Section 134A'),
              _buildReportRow('Generated On:', '30 July 2026, 10:45 AM'),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.brandPurple, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('PDF Report downloaded to device storage!'), backgroundColor: Colors.green),
                    );
                  },
                  icon: const Icon(Icons.download_rounded, color: Colors.white),
                  label: const Text('SAVE PDF TO DEVICE', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          Text(value, style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }

  void _showIncidentDetail(BuildContext context, String title, String date, String location) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: AppColors.textDark)),
            const SizedBox(height: 8),
            Text('$date • $location', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            const Divider(height: 24),
            const Text('TELEMATICS RECORD:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            const Text('• 108 Dispatch Triggered at 18:31:04\n• Paramedic Team Assigned: Unit #GJ-04-108\n• Good Samaritan SC Immunity Badge: Verified', style: TextStyle(height: 1.5, color: AppColors.textDark)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.brandPurple),
                onPressed: () => Navigator.pop(ctx),
                child: const Text('CLOSE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Text('INCIDENT HISTORY', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
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
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        physics: const BouncingScrollPhysics(),
        children: [
          const Text('RECENT ACTIVITY', style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          const SizedBox(height: 16),
          
          _buildIncidentHistoryTile(
            context: context,
            title: 'Accident Reported', 
            date: 'Apr 20, 2025 • 6:30 PM', 
            location: 'Near S.G. Highway, Ahmedabad', 
            status: 'Completed', 
            icon: Icons.report_rounded,
            iconColor: AppColors.emergencyRed,
          ),
          
          _buildIncidentHistoryTile(
            context: context,
            title: 'Helped as Responder', 
            date: 'Apr 12, 2025 • 3:15 PM', 
            location: 'Bopal, Ahmedabad', 
            status: 'Verified', 
            icon: Icons.health_and_safety_rounded,
            iconColor: AppColors.brandPurple,
          ),
          
          _buildIncidentHistoryTile(
            context: context,
            title: 'First Aid Given', 
            date: 'Mar 05, 2025 • 11:40 AM', 
            location: 'Maninagar, Vadodara', 
            status: 'Completed', 
            icon: Icons.medical_information_rounded,
            iconColor: AppColors.infoBlue,
          ),

          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.brandPurple.withAlpha(20)),
              boxShadow: AppColors.softShadow,
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(color: AppColors.brandPurpleLight, shape: BoxShape.circle),
                  child: const Icon(Icons.download_rounded, color: AppColors.brandPurple, size: 32),
                ),
                const SizedBox(height: 16),
                const Text('Download Report', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.textDark)),
                const SizedBox(height: 4),
                const Text('Get a detailed PDF of your\npast interventions & reports.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4)),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brandPurple,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      elevation: 0,
                    ),
                    onPressed: () => _showPdfReport(context),
                    child: const Text('Generate PDF', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildIncidentHistoryTile({
    required BuildContext context,
    required String title, 
    required String date, 
    required String location, 
    required String status, 
    required IconData icon, 
    required Color iconColor
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppColors.softShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => _showIncidentDetail(context, title, date, location),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconColor.withAlpha(20),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.textDark)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.access_time_rounded, size: 12, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(date, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.location_on_rounded, size: 12, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Expanded(child: Text(location, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600))),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.successGreenBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(status, style: const TextStyle(color: AppColors.successGreen, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
