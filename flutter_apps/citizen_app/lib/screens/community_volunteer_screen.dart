// Flutter Screen 15: Community & Volunteer — Real Registration + Events
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers/auth_provider.dart';

class CommunityVolunteerScreen extends StatefulWidget {
  const CommunityVolunteerScreen({Key? key}) : super(key: key);

  @override
  State<CommunityVolunteerScreen> createState() => _CommunityVolunteerScreenState();
}

class _CommunityVolunteerScreenState extends State<CommunityVolunteerScreen> {
  bool _isVolunteer = false;
  bool _isJoining = false;

  @override
  void initState() {
    super.initState();
    _checkVolunteerStatus();
  }

  Future<void> _checkVolunteerStatus() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      final doc = await FirebaseFirestore.instance.collection('volunteers').doc(uid).get();
      if (mounted) setState(() => _isVolunteer = doc.exists);
    } catch (_) {}
  }

  Future<void> _joinNetwork() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    setState(() => _isJoining = true);
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      await FirebaseFirestore.instance.collection('volunteers').doc(uid).set({
        'uid': uid,
        'name': auth.userName,
        'phone': auth.userPhone,
        'city': auth.districtState.split(',').first.trim(),
        'joinedAt': FieldValue.serverTimestamp(),
        'trainingsCompleted': 0,
        'emergenciesHelped': 0,
      });
      if (mounted) {
        setState(() { _isVolunteer = true; _isJoining = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Welcome to the Sahay Volunteer Network!'),
            backgroundColor: AppColors.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isJoining = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error joining: $e'), backgroundColor: AppColors.emergencyRed),
        );
      }
    }
  }

  // Events data — could be loaded from Firestore in production
  static final List<Map<String, dynamic>> _events = [
    {
      'title': 'First Aid Workshop',
      'date': 'Aug 15, 2026 • Bhavnagar',
      'tag': 'First Aid',
      'icon': Icons.medical_information_rounded,
      'color': Colors.orange,
      'description': 'Learn essential first aid techniques — bandaging, splinting, and wound care. Open to all citizens.',
    },
    {
      'title': 'CPR Awareness Drive',
      'date': 'Aug 22, 2026 • Ahmedabad',
      'tag': 'CPR Training',
      'icon': Icons.favorite_rounded,
      'color': AppColors.emergencyRed,
      'description': 'Hands-on CPR training with mannequins. Get certified as a Golden Hour First Responder.',
    },
    {
      'title': 'Road Safety Camp',
      'date': 'Sep 05, 2026 • Rajkot',
      'tag': 'Community',
      'icon': Icons.add_road_rounded,
      'color': AppColors.brandPurple,
      'description': 'Learn accident scene management, Good Samaritan Law awareness, and emergency response protocols.',
    },
    {
      'title': 'Disaster Response Workshop',
      'date': 'Sep 15, 2026 • Vadodara',
      'tag': 'Emergency',
      'icon': Icons.warning_rounded,
      'color': Colors.deepOrange,
      'description': 'Prepare for flood, earthquake, and fire emergencies. Learn evacuation and rescue techniques.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: const Text('COMMUNITY & VOLUNTEER', style: TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
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
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Join Network Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.brandPurple, Color(0xFF6B3CE2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: AppColors.brandPurple.withAlpha(100), blurRadius: 20, spreadRadius: 5)],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: Colors.white.withAlpha(40), shape: BoxShape.circle),
                      child: Icon(
                        _isVolunteer ? Icons.verified_rounded : Icons.groups_rounded,
                        size: 56,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _isVolunteer ? '✅ You\'re a Volunteer!' : 'Be a Volunteer',
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 28, color: Colors.white, letterSpacing: -0.5),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isVolunteer
                          ? 'Thank you for being part of the Sahay network. Your contribution saves lives.'
                          : 'Join our civic network & save more lives in your community.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600, height: 1.4),
                    ),
                    const SizedBox(height: 32),
                    if (!_isVolunteer)
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                          onPressed: _isJoining ? null : _joinNetwork,
                          child: _isJoining
                              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.brandPurple))
                              : const Text('JOIN NETWORK NOW', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.brandPurple, letterSpacing: 1)),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Volunteer Stats (if registered)
              if (_isVolunteer) ...[
                _buildVolunteerStats(),
                const SizedBox(height: 32),
              ],

              // Events
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Upcoming Events', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.white, letterSpacing: -0.5)),
                  Text('${_events.length} Events', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.brandPurpleLight)),
                ],
              ),
              const SizedBox(height: 16),

              ..._events.map((e) => _buildEventCard(context, e)),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVolunteerStats() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('volunteers')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .snapshots(),
      builder: (context, snapshot) {
        int trainings = 0;
        int helped = 0;
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>?;
          trainings = data?['trainingsCompleted'] ?? 0;
          helped = data?['emergenciesHelped'] ?? 0;
        }
        return Row(
          children: [
            _buildMiniStat('$helped', 'People Helped', AppColors.successGreen, Icons.favorite_rounded),
            const SizedBox(width: 12),
            _buildMiniStat('$trainings', 'Trainings Done', AppColors.infoBlue, Icons.school_rounded),
          ],
        );
      },
    );
  }

  Widget _buildMiniStat(String val, String label, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bgCardDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withAlpha(20), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(val, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: color)),
                Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, Map<String, dynamic> event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.bgCardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showEventDetails(context, event),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: (event['color'] as Color).withAlpha(20), shape: BoxShape.circle),
                  child: Icon(event['icon'] as IconData, color: event['color'] as Color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(event['title'] as String, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Colors.white)),
                      const SizedBox(height: 4),
                      Text(event['date'] as String, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: AppColors.primaryPurpleLight.withAlpha(20), borderRadius: BorderRadius.circular(10)),
                  child: Text(event['tag'] as String, style: const TextStyle(color: AppColors.primaryPurpleLight, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEventDetails(BuildContext context, Map<String, dynamic> event) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgCardDark,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 24),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: (event['color'] as Color).withAlpha(20), shape: BoxShape.circle),
                  child: Icon(event['icon'] as IconData, color: event['color'] as Color, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(event['title'] as String, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.white)),
                      const SizedBox(height: 4),
                      Text(event['date'] as String, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(event['description'] as String, style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5, fontWeight: FontWeight.w500)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: event['color'] as Color, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('✅ Registered for ${event['title']}'), backgroundColor: AppColors.successGreen),
                  );
                },
                child: const Text('REGISTER FOR EVENT', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Colors.white, letterSpacing: 0.5)),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
