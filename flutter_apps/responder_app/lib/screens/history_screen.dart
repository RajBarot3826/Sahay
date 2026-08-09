import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_colors.dart';
import '../providers/responder_state.dart';
import '../services/firebase_dispatch_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final FirebaseDispatchService _dispatchService = FirebaseDispatchService();
  List<Map<String, dynamic>> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final state = Provider.of<ResponderState>(context, listen: false);
    final history = await _dispatchService.getMissionHistory(state.phone);
    if (mounted) {
      setState(() {
        _history = history;
        _isLoading = false;
      });
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
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: AppColors.softShadow),
                        child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.textDark),
                      ),
                    ).animate().scale(curve: Curves.easeOutBack, duration: 300.ms),
                    const Expanded(
                      child: Center(
                        child: Text(
                          'MISSION LOGS',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.primaryPurple, letterSpacing: 2.0),
                        ),
                      ),
                    ),
                    const SizedBox(width: 42),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Center(child: CircularProgressIndicator(color: AppColors.primaryPurple)),
                )
              else if (_history.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Center(child: Text('No missions completed yet.', style: TextStyle(color: AppColors.textGrey))),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: _history.length,
                  itemBuilder: (context, index) {
                    return _buildHistoryCard(_history[index], index);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> data, int index) {
    String dateStr = 'Unknown Date';
    if (data['completedAt'] != null) {
      final timestamp = data['completedAt'] as Timestamp;
      final date = timestamp.toDate();
      dateStr = DateFormat('MMM dd, HH:mm').format(date);
    }
    
    final hospital = data['hospital'] ?? 'Unknown Hospital';
    final type = data['emergencyType'] ?? 'Emergency';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: AppColors.successGreenLight, borderRadius: BorderRadius.circular(8)),
                child: const Text('COMPLETED', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.successGreen)),
              ),
              Text(dateStr, style: const TextStyle(color: AppColors.textGrey, fontWeight: FontWeight.w700, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 16),
          Text(type, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textDark)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.local_hospital_rounded, size: 16, color: AppColors.primaryPurple),
              const SizedBox(width: 8),
              Expanded(child: Text('Handover: $hospital', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textDark), overflow: TextOverflow.ellipsis)),
            ],
          ),
        ],
      ),
    ).animate().fade(delay: (100 * index).ms).slideY(begin: 0.1);
  }
}
