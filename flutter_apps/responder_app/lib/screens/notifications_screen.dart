import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers/responder_state.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final responderState = Provider.of<ResponderState>(context, listen: false);

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SafeArea(
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
                        'NOTIFICATIONS',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.primaryPurple, letterSpacing: 2.0),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _markAllAsRead(responderState.phone),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: AppColors.softShadow),
                      child: const Icon(Icons.done_all_rounded, size: 18, color: AppColors.successGreen),
                    ),
                  ).animate().scale(curve: Curves.easeOutBack, duration: 300.ms),
                ],
              ),
            ),

            // Filters
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                children: [
                  _buildFilterTab('All'),
                  const SizedBox(width: 8),
                  _buildFilterTab('Emergency'),
                  const SizedBox(width: 8),
                  _buildFilterTab('Mission Updates'),
                ],
              ),
            ),
            
            const SizedBox(height: 8),

            // List
            Expanded(
              child: responderState.phone.isEmpty
                  ? _buildEmptyState()
                  : StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('responders')
                          .doc(responderState.phone)
                          .collection('notifications')
                          .orderBy('timestamp', descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator(color: AppColors.primaryPurple));
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return _buildEmptyState();
                        }

                        final docs = snapshot.data!.docs.where((doc) {
                          if (_selectedFilter == 'All') return true;
                          final data = doc.data() as Map<String, dynamic>;
                          return data['category'] == _selectedFilter;
                        }).toList();

                        if (docs.isEmpty) {
                          return _buildEmptyState();
                        }

                        return RefreshIndicator(
                          onRefresh: () async {},
                          color: AppColors.primaryPurple,
                          child: ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                            itemCount: docs.length,
                            itemBuilder: (context, index) {
                              return _buildNotificationCard(docs[index], index);
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTab(String label) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryPurple : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected ? AppColors.glowPurple : AppColors.softShadow,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: isSelected ? Colors.white : AppColors.textGrey,
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(DocumentSnapshot doc, int index) {
    final data = doc.data() as Map<String, dynamic>;
    final isUnread = !(data['read'] as bool? ?? true);
    final title = data['title'] ?? '';
    final body = data['body'] ?? '';
    final category = data['category'] ?? 'System';
    final timestamp = data['timestamp'] as Timestamp?;
    
    String timeAgo = 'Just now';
    if (timestamp != null) {
      final diff = DateTime.now().difference(timestamp.toDate());
      if (diff.inDays > 0) {
        timeAgo = '${diff.inDays}d ago';
      } else if (diff.inHours > 0) {
        timeAgo = '${diff.inHours}h ago';
      } else if (diff.inMinutes > 0) {
        timeAgo = '${diff.inMinutes}m ago';
      }
    }

    Color iconColor = AppColors.primaryPurple;
    Color bgColor = AppColors.primaryPurpleLight;
    IconData icon = Icons.notifications_active_rounded;

    if (category == 'Emergency') {
      iconColor = AppColors.emergencyRed;
      bgColor = AppColors.emergencyRedBg;
      icon = Icons.warning_rounded;
    } else if (category == 'Mission Updates') {
      iconColor = AppColors.infoBlue;
      bgColor = const Color(0xFFE0F2FE);
      icon = Icons.local_taxi_rounded;
    }

    return GestureDetector(
      onTap: () {
        if (isUnread) {
          doc.reference.update({'read': true});
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isUnread ? Colors.white : Colors.white.withOpacity(0.6),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isUnread ? iconColor.withOpacity(0.3) : Colors.transparent, width: 2),
          boxShadow: isUnread ? AppColors.softShadow : [],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUnread ? bgColor : AppColors.bgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: isUnread ? iconColor : AppColors.textGrey, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title, 
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.textDark),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                      ),
                      if (isUnread) ...[
                        const SizedBox(width: 8),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(color: AppColors.emergencyRed, shape: BoxShape.circle),
                        ),
                      ]
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    body,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textGrey, height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  Text(timeAgo, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textGrey.withOpacity(0.5))),
                ],
              ),
            ),
          ],
        ),
      ).animate().fade(delay: (50 * index).ms).slideY(begin: 0.1),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_rounded, size: 80, color: AppColors.textGrey.withOpacity(0.3)),
          const SizedBox(height: 24),
          const Text(
            'No Notifications',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textDark),
          ),
          const SizedBox(height: 8),
          const Text(
            'You are all caught up.',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textGrey),
          ),
        ],
      ).animate().fade().scale(curve: Curves.easeOutBack),
    );
  }

  Future<void> _markAllAsRead(String phone) async {
    if (phone.isEmpty) return;
    
    final query = await FirebaseFirestore.instance
        .collection('responders')
        .doc(phone)
        .collection('notifications')
        .where('read', isEqualTo: false)
        .limit(500)
        .get();
        
    final batch = FirebaseFirestore.instance.batch();
    for (var doc in query.docs) {
      batch.update(doc.reference, {'read': true});
    }
    
    await batch.commit();
  }
}
