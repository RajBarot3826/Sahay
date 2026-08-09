// Flutter Screen 17: Rewards & Badges — Real Gamification from Firestore + SharedPreferences
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_colors.dart';

class RewardsBadgesScreen extends StatefulWidget {
  const RewardsBadgesScreen({Key? key}) : super(key: key);

  @override
  State<RewardsBadgesScreen> createState() => _RewardsBadgesScreenState();
}

class _RewardsBadgesScreenState extends State<RewardsBadgesScreen> {
  int _totalPoints = 0;
  int _emergenciesHelped = 0;
  int _trainingsCompleted = 0;
  int _certificatesGenerated = 0;
  final Map<String, bool> _earnedBadges = {};
  bool _isLoading = true;

  static final List<Map<String, dynamic>> _allBadges = [
    {'id': 'first_responder', 'icon': Icons.workspace_premium_rounded, 'label': 'First Responder', 'color': Colors.orange, 'requirement': 'Trigger your first SOS', 'points': 100},
    {'id': 'life_saver', 'icon': Icons.favorite_rounded, 'label': 'Life Saver', 'color': AppColors.emergencyRed, 'requirement': 'Help resolve 1 emergency', 'points': 250},
    {'id': 'cpr_hero', 'icon': Icons.volunteer_activism_rounded, 'label': 'CPR Certified', 'color': AppColors.brandPurple, 'requirement': 'Complete CPR training', 'points': 150},
    {'id': 'first_aid_trained', 'icon': Icons.medical_information_rounded, 'label': 'First Aid Pro', 'color': Colors.orange, 'requirement': 'Complete First Aid module', 'points': 150},
    {'id': 'good_samaritan', 'icon': Icons.shield_rounded, 'label': 'Good Samaritan', 'color': AppColors.successGreen, 'requirement': 'Generate a legal certificate', 'points': 200},
    {'id': 'community_hero', 'icon': Icons.groups_rounded, 'label': 'Community Hero', 'color': Colors.deepOrange, 'requirement': 'Join volunteer network', 'points': 100},
    {'id': 'bleeding_expert', 'icon': Icons.bloodtype_rounded, 'label': 'Bleeding Control', 'color': AppColors.emergencyRed, 'requirement': 'Complete bleeding module', 'points': 150},
    {'id': 'road_protocol', 'icon': Icons.add_road_rounded, 'label': 'Road Protocol', 'color': AppColors.brandPurple, 'requirement': 'Complete road accident module', 'points': 150},
    {'id': 'golden_hour', 'icon': Icons.emoji_events_rounded, 'label': 'Golden Hour ★', 'color': Colors.amber, 'requirement': 'Complete ALL training modules', 'points': 500},
  ];

  @override
  void initState() {
    super.initState();
    _loadBadgesAndPoints();
  }

  Future<void> _loadBadgesAndPoints() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = FirebaseAuth.instance.currentUser?.uid;

      // Check training module completions
      final trainingModules = ['first_aid', 'cpr', 'bleeding', 'road_safety'];
      int completedTrainings = 0;
      for (final mod in trainingModules) {
        if (prefs.getBool('module_$mod') ?? false) completedTrainings++;
      }
      _trainingsCompleted = completedTrainings;

      // Map training completions to badges
      if (prefs.getBool('module_first_aid') ?? false) _earnedBadges['first_aid_trained'] = true;
      if (prefs.getBool('module_cpr') ?? false) _earnedBadges['cpr_hero'] = true;
      if (prefs.getBool('module_bleeding') ?? false) _earnedBadges['bleeding_expert'] = true;
      if (prefs.getBool('module_road_safety') ?? false) _earnedBadges['road_protocol'] = true;
      if (completedTrainings == trainingModules.length) _earnedBadges['golden_hour'] = true;

      // Check Firestore data
      if (uid != null) {
        // Check if volunteer
        final volunteerDoc = await FirebaseFirestore.instance.collection('volunteers').doc(uid).get();
        if (volunteerDoc.exists) _earnedBadges['community_hero'] = true;

        // Count certificates
        final certs = await FirebaseFirestore.instance
            .collection('users').doc(uid).collection('certificates').get();
        _certificatesGenerated = certs.size;
        if (_certificatesGenerated > 0) _earnedBadges['good_samaritan'] = true;

        // Count emergencies where user was the caller
        final emergencies = await FirebaseFirestore.instance
            .collection('emergencies')
            .where('userId', isEqualTo: uid)
            .get();
        if (emergencies.size > 0) _earnedBadges['first_responder'] = true;
        
        final resolved = emergencies.docs.where((d) => d.data()['status'] == 'resolved').length;
        _emergenciesHelped = resolved;
        if (resolved > 0) _earnedBadges['life_saver'] = true;
      }

      // Calculate points
      _totalPoints = 0;
      for (final badge in _allBadges) {
        if (_earnedBadges[badge['id']] == true) {
          _totalPoints += badge['points'] as int;
        }
      }

      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    final earnedCount = _earnedBadges.values.where((v) => v).length;

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Text('REWARDS & BADGES', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.brandPurple))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Points Trophy Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: AppColors.glowPurple,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Total Points', style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Text('$_totalPoints', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 42, color: Colors.white, letterSpacing: -1)),
                            const SizedBox(height: 4),
                            Text('$earnedCount / ${_allBadges.length} badges earned', style: TextStyle(color: Colors.white.withAlpha(180), fontSize: 12, fontWeight: FontWeight.w600)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: Colors.white.withAlpha(50), shape: BoxShape.circle),
                          child: const Icon(Icons.emoji_events_rounded, size: 48, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Stats Row
                  Row(
                    children: [
                      _buildMiniStat('$_emergenciesHelped', 'Helped', AppColors.successGreen),
                      const SizedBox(width: 8),
                      _buildMiniStat('$_trainingsCompleted', 'Trained', AppColors.infoBlue),
                      const SizedBox(width: 8),
                      _buildMiniStat('$_certificatesGenerated', 'Certs', AppColors.brandPurple),
                    ],
                  ),
                  const SizedBox(height: 32),

                  const Text('ALL BADGES', style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                  const SizedBox(height: 16),

                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.72,
                    children: _allBadges.map((badge) {
                      final isEarned = _earnedBadges[badge['id']] == true;
                      return _buildBadgeItem(badge, isEarned);
                    }).toList(),
                  ),
                  const SizedBox(height: 32),

                  // How to earn
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.grey.withAlpha(20)),
                      boxShadow: AppColors.softShadow,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: AppColors.bgLight, shape: BoxShape.circle),
                          child: const Icon(Icons.info_outline_rounded, color: AppColors.textSecondary, size: 24),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Text('Earn points by completing training, helping victims, generating certificates, and joining the volunteer network.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildMiniStat(String val, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColors.softShadow,
        ),
        child: Column(
          children: [
            Text(val, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: color)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgeItem(Map<String, dynamic> badge, bool isEarned) {
    final color = badge['color'] as Color;
    return GestureDetector(
      onTap: () => _showBadgeDetails(badge, isEarned),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppColors.softShadow,
          border: isEarned ? Border.all(color: color, width: 2) : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isEarned ? color.withAlpha(20) : Colors.grey.withAlpha(15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                badge['icon'] as IconData,
                color: isEarned ? color : Colors.grey.withAlpha(80),
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                badge['label'] as String,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  color: isEarned ? AppColors.textDark : Colors.grey,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
              ),
            ),
            const SizedBox(height: 4),
            if (isEarned)
              Text('+${badge['points']}pts', style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.w900))
            else
              Icon(Icons.lock_outline_rounded, size: 12, color: Colors.grey.withAlpha(80)),
          ],
        ),
      ),
    );
  }

  void _showBadgeDetails(Map<String, dynamic> badge, bool isEarned) {
    final color = badge['color'] as Color;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.withAlpha(40), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: color.withAlpha(20), shape: BoxShape.circle),
              child: Icon(badge['icon'] as IconData, color: color, size: 48),
            ),
            const SizedBox(height: 16),
            Text(badge['label'] as String, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: isEarned ? color : Colors.grey)),
            const SizedBox(height: 8),
            Text('+${badge['points']} points', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: color.withAlpha(180))),
            const SizedBox(height: 12),
            Text(badge['requirement'] as String, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: isEarned ? AppColors.successGreen.withAlpha(20) : Colors.grey.withAlpha(15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isEarned ? '✅ EARNED' : '🔒 LOCKED',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: isEarned ? AppColors.successGreen : Colors.grey),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
