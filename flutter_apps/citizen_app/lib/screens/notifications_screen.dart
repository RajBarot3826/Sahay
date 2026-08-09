// Flutter Screen: Notifications — Real Firestore Data
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers/auth_provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  int _selectedIndex = 0;

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'Unknown';
    if (timestamp is Timestamp) {
      final dt = timestamp.toDate();
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inMinutes < 60) return '${diff.inMinutes} mins ago';
      if (diff.inHours < 24) return '${diff.inHours} hours ago';
      return '${dt.day}/${dt.month}/${dt.year}';
    }
    return 'Unknown';
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'ambulance': return Icons.airport_shuttle_rounded;
      case 'hospital': return Icons.local_hospital_rounded;
      case 'responder': return Icons.person_rounded;
      case 'training': return Icons.school_rounded;
      case 'sos': return Icons.warning_amber_rounded;
      default: return Icons.notifications_rounded;
    }
  }

  Color _getColor(String type) {
    switch (type) {
      case 'ambulance': return AppColors.emergencyRed;
      case 'hospital': return AppColors.infoBlue;
      case 'responder': return AppColors.successGreen;
      case 'sos': return AppColors.emergencyRed;
      default: return AppColors.brandPurple;
    }
  }

  Future<void> _markAllAsRead(String uid) async {
    final batch = FirebaseFirestore.instance.batch();
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .where('read', isEqualTo: false)
        .limit(500)
        .get();

    for (var doc in snapshot.docs) {
      batch.update(doc.reference, {'read': true});
    }

    await batch.commit();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All notifications marked as read!'), backgroundColor: AppColors.brandPurple),
      );
    }
  }

  Future<void> _markAsRead(String uid, String docId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .doc(docId)
        .update({'read': true});
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final uid = FirebaseAuth.instance.currentUser?.uid ?? auth.userPhone;

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Text('NOTIFICATIONS', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
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
      body: SafeArea(
        child: Column(
          children: [
            // Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Row(
                children: [
                  _buildTab('All', 0),
                  const SizedBox(width: 8),
                  _buildTab('Alerts', 1),
                  const SizedBox(width: 8),
                  _buildTab('Updates', 2),
                ],
              ),
            ),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .collection('notifications')
                    .orderBy('timestamp', descending: true)
                    .limit(50)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.brandPurple));
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final docs = snapshot.data?.docs ?? [];
                  
                  final filteredDocs = docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    if (_selectedIndex == 1) return data['category'] == 'Alerts';
                    if (_selectedIndex == 2) return data['category'] == 'Updates';
                    return true;
                  }).toList();

                  if (filteredDocs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.notifications_off_rounded, size: 64, color: AppColors.textSecondary.withAlpha(80)),
                          const SizedBox(height: 16),
                          const Text('No notifications yet', style: TextStyle(color: AppColors.textSecondary, fontSize: 16, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 8),
                          const Text('Notifications will appear here\nwhen you trigger SOS or receive alerts', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      setState(() {});
                    },
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: filteredDocs.length,
                      itemBuilder: (context, index) {
                        final doc = filteredDocs[index];
                        final data = doc.data() as Map<String, dynamic>;
                        final isUnread = !(data['read'] as bool? ?? false);
                        
                        return _buildNotificationItem(
                          _getIcon(data['type'] ?? 'info'),
                          data['title'] ?? 'Notification',
                          data['body'] ?? '',
                          _formatTimestamp(data['timestamp']),
                          _getColor(data['type'] ?? 'info'),
                          isUnread: isUnread,
                          onTap: () {
                            if (isUnread) _markAsRead(uid, doc.id);
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                title: Text(data['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                                content: Text(data['body'] ?? ''),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),

            Container(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: () => _markAllAsRead(uid),
                  icon: const Icon(Icons.done_all_rounded, color: AppColors.brandPurple),
                  label: const Text('Mark all as read', style: TextStyle(color: AppColors.brandPurple, fontWeight: FontWeight.bold, fontSize: 14)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.brandPurple : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected ? AppColors.softShadow : [],
          border: Border.all(color: isSelected ? AppColors.brandPurple : Colors.black.withAlpha(10)),
        ),
        child: Text(label, style: TextStyle(color: isSelected ? Colors.white : AppColors.textSecondary, fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold, fontSize: 13)),
      ),
    );
  }

  Widget _buildNotificationItem(IconData icon, String title, String body, String time, Color color, {bool isUnread = false, VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isUnread ? Colors.white : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        boxShadow: isUnread ? AppColors.softShadow : [],
        border: Border.all(color: isUnread ? color.withAlpha(30) : Colors.black.withAlpha(5)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: color.withAlpha(20), shape: BoxShape.circle),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.textDark))),
                          if (isUnread) Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.brandPurple, shape: BoxShape.circle))
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(body, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4)),
                      const SizedBox(height: 8),
                      Text(time, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
