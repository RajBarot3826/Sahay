// Senior Architect UI — Screen 23: Impact Dashboard & Statistics
// Pulls REAL data from Firestore emergencies collection
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_colors.dart';

class ImpactDashboardScreen extends StatefulWidget {
  const ImpactDashboardScreen({Key? key}) : super(key: key);

  @override
  State<ImpactDashboardScreen> createState() => _ImpactDashboardScreenState();
}

class _ImpactDashboardScreenState extends State<ImpactDashboardScreen> {
  int _totalEmergencies = 0;
  int _resolvedCount = 0;
  int _activeResponders = 0;
  double _avgResponseTimeMins = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      // Count total emergencies
      final emergencies = await FirebaseFirestore.instance
          .collection('emergencies')
          .get();
      _totalEmergencies = emergencies.size;

      // Count resolved emergencies (lives impacted)
      int resolved = 0;
      double totalResponseTime = 0;
      int responseTimes = 0;

      for (final doc in emergencies.docs) {
        final data = doc.data();
        if (data['status'] == 'resolved') {
          resolved++;
          // Calculate response time if we have both timestamps
          final created = data['timestamp'] as Timestamp?;
          final resolvedAt = data['resolvedAt'] as Timestamp?;
          if (created != null && resolvedAt != null) {
            final diff = resolvedAt.toDate().difference(created.toDate()).inMinutes;
            if (diff > 0 && diff < 120) { // Filter outliers
              totalResponseTime += diff;
              responseTimes++;
            }
          }
        }
      }
      _resolvedCount = resolved;
      _avgResponseTimeMins = responseTimes > 0 ? totalResponseTime / responseTimes : 0;

      // Count active responders
      final responders = await FirebaseFirestore.instance
          .collection('responders')
          .where('isOnline', isEqualTo: true)
          .get();
      _activeResponders = responders.size;

      // Also get total responders
      final allResponders = await FirebaseFirestore.instance
          .collection('responders')
          .get();

      setState(() {
        _isLoading = false;
        _activeResponders = allResponders.size > 0 ? allResponders.size : _activeResponders;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: const Text('IMPACT DASHBOARD', style: TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: AppColors.bgCardDark, shape: BoxShape.circle, border: Border.all(color: Colors.white12)),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
            onPressed: () { setState(() => _isLoading = true); _loadStats(); },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.brandPurpleLight))
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Overview', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: Colors.white, letterSpacing: -0.5)),
                  const SizedBox(height: 8),
                  Text(
                    'Real-time data from Sahay network',
                    style: TextStyle(color: Colors.white.withAlpha(120), fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 24),

                  // Metrics Cards Grid
                  Row(
                    children: [
                      _buildStatCard('$_resolvedCount', 'Lives Impacted', AppColors.successGreen, Icons.favorite_rounded),
                      const SizedBox(width: 12),
                      _buildStatCard('$_totalEmergencies', 'Total Emergencies', AppColors.infoBlue, Icons.campaign_rounded),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildStatCard(
                        _avgResponseTimeMins > 0 ? '${_avgResponseTimeMins.toStringAsFixed(1)}m' : '—',
                        'Avg Response',
                        AppColors.warningAmber,
                        Icons.timer_rounded,
                      ),
                      const SizedBox(width: 12),
                      _buildStatCard('$_activeResponders', 'Responders', AppColors.brandPurpleLight, Icons.groups_rounded),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Mission Breakdown
                  const Text('Mission Breakdown', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white, letterSpacing: -0.5)),
                  const SizedBox(height: 16),
                  _buildBreakdownCard(),

                  const SizedBox(height: 32),

                  // Recent Activity
                  const Text('Recent Activity', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white, letterSpacing: -0.5)),
                  const SizedBox(height: 16),
                  _buildRecentActivity(),
                ],
              ),
            ),
    );
  }

  Widget _buildBreakdownCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.bgCardDark,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          _buildBreakdownRow('Resolved', _resolvedCount, AppColors.successGreen),
          const Divider(color: Colors.white12, height: 24),
          _buildBreakdownRow('Cancelled', _totalEmergencies - _resolvedCount, AppColors.warningAmber),
          const Divider(color: Colors.white12, height: 24),
          _buildBreakdownRow('Success Rate',
            _totalEmergencies > 0 ? ((_resolvedCount / _totalEmergencies) * 100).round() : 0,
            AppColors.brandPurpleLight,
            suffix: '%',
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownRow(String label, int value, Color color, {String suffix = ''}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600)),
          ],
        ),
        Text('$value$suffix', style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w900)),
      ],
    );
  }

  Widget _buildRecentActivity() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('emergencies')
          .orderBy('timestamp', descending: true)
          .limit(5)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator(color: AppColors.brandPurpleLight));
        }

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(color: AppColors.bgCardDark, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white12)),
            child: const Center(child: Text('No emergencies recorded yet', style: TextStyle(color: Colors.white54, fontSize: 14))),
          );
        }

        return Column(
          children: docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final status = data['status'] ?? 'unknown';
            final type = data['type'] ?? 'unknown';
            final timestamp = data['timestamp'] as Timestamp?;
            final timeStr = timestamp != null
                ? '${timestamp.toDate().day}/${timestamp.toDate().month} ${timestamp.toDate().hour}:${timestamp.toDate().minute.toString().padLeft(2, '0')}'
                : '—';

            final statusColor = status == 'resolved'
                ? AppColors.successGreen
                : status == 'cancelled'
                    ? AppColors.warningAmber
                    : AppColors.infoBlue;

            final statusIcon = status == 'resolved'
                ? Icons.check_circle_rounded
                : status == 'cancelled'
                    ? Icons.cancel_rounded
                    : Icons.radio_button_checked_rounded;

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.bgCardDark,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: statusColor.withAlpha(20), shape: BoxShape.circle),
                    child: Icon(statusIcon, color: statusColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(type.toString().toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                        const SizedBox(height: 2),
                        Text(timeStr, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: statusColor.withAlpha(20), borderRadius: BorderRadius.circular(8)),
                    child: Text(status.toString().toUpperCase(), style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildStatCard(String val, String label, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: AppColors.bgCardDark,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white12),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(30), blurRadius: 10)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withAlpha(20), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 16),
            Text(val, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 26, color: color, letterSpacing: -0.5)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
