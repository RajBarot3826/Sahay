// Flutter Screen 20: Offline Mode — Real offline-accessible first aid guides + emergency numbers
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_colors.dart';

class OfflineModeScreen extends StatelessWidget {
  const OfflineModeScreen({Key? key}) : super(key: key);

  // Emergency numbers that work without internet
  static const List<Map<String, String>> _emergencyNumbers = [
    {'name': 'National Emergency', 'number': '112', 'icon': 'emergency'},
    {'name': 'Ambulance', 'number': '108', 'icon': 'ambulance'},
    {'name': 'Police', 'number': '100', 'icon': 'police'},
    {'name': 'Fire Brigade', 'number': '101', 'icon': 'fire'},
    {'name': 'Women Helpline', 'number': '1091', 'icon': 'women'},
    {'name': 'Child Helpline', 'number': '1098', 'icon': 'child'},
  ];

  // Complete offline first aid guides
  static const List<Map<String, String>> _firstAidGuides = [
    {
      'title': 'CPR (No Pulse)',
      'steps': '1. Call 112 immediately\n2. Place heel of hand on center of chest\n3. Push HARD & FAST — 100-120 per minute\n4. Push 5cm deep minimum\n5. After 30 pushes → 2 rescue breaths\n6. Continue until help arrives\n\nRemember: "Stayin\' Alive" tempo',
    },
    {
      'title': 'Heavy Bleeding',
      'steps': '1. Apply FIRM pressure with clean cloth\n2. Do NOT remove cloth if soaked — add more on top\n3. Elevate wound above heart if possible\n4. If arm/leg won\'t stop → tourniquet 2" above wound\n5. Note the TIME of tourniquet\n6. Keep victim warm — prevent shock',
    },
    {
      'title': 'Choking (Adult)',
      'steps': '1. Ask: "Are you choking?" — if they can\'t speak:\n2. Stand behind them\n3. Make a fist above navel\n4. Grab fist with other hand\n5. Pull sharply INWARD and UPWARD\n6. Repeat until object comes out\n7. If unconscious → start CPR',
    },
    {
      'title': 'Burns',
      'steps': '1. Cool under running water 10-20 minutes\n2. Do NOT use ice, butter, or toothpaste\n3. Remove jewelry near burn before swelling\n4. Cover with clean, non-fluffy material\n5. Do NOT pop blisters\n6. Seek medical help for burns larger than palm',
    },
    {
      'title': 'Fracture/Broken Bone',
      'steps': '1. Do NOT move the injured limb\n2. Support it in the position you find it\n3. Apply cold pack wrapped in cloth\n4. Immobilize with splint (cardboard, stick, magazine)\n5. Tie above and below the break, NOT on it\n6. Check circulation below splint regularly',
    },
    {
      'title': 'Heart Attack Signs',
      'steps': 'SIGNS:\n• Crushing chest pain / pressure\n• Pain radiating to arm, jaw, back\n• Shortness of breath, sweating\n• Nausea, dizziness\n\nACTION:\n1. Call 112 immediately\n2. Make person sit/lie comfortably\n3. Give aspirin if available (chew, don\'t swallow)\n4. Be ready to perform CPR',
    },
    {
      'title': 'Recovery Position',
      'steps': '(For unconscious person who IS breathing)\n1. Kneel beside the person\n2. Place far arm across chest, hand on cheek\n3. Bend far knee up\n4. Roll them gently onto their side\n5. Tilt head back to open airway\n6. Stay with them until help arrives\n\n⚠️ Do NOT use if spinal injury suspected',
    },
  ];

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Text('OFFLINE MODE', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.emergencyRed.withAlpha(10),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.emergencyRed.withAlpha(30)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppColors.emergencyRed, shape: BoxShape.circle),
                    child: const Icon(Icons.wifi_off_rounded, size: 24, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Offline Mode Active', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.textDark)),
                        SizedBox(height: 2),
                        Text('All content below is cached locally', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Emergency Numbers Section
            const Text('EMERGENCY NUMBERS', style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const SizedBox(height: 12),
            ..._emergencyNumbers.map((num) => _buildEmergencyNumberRow(context, num)),

            const SizedBox(height: 32),

            // First Aid Guides Section
            const Text('FIRST AID QUICK GUIDES', style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const SizedBox(height: 12),
            ..._firstAidGuides.map((guide) => _buildGuideCard(context, guide)),

            const SizedBox(height: 24),

            // Sync Notice
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppColors.softShadow,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: AppColors.bgLight, shape: BoxShape.circle),
                    child: const Icon(Icons.sync_rounded, color: AppColors.brandPurple, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text('Data will automatically sync\nonce you are back online.', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyNumberRow(BuildContext context, Map<String, String> number) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _callNumber(number['number']!),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: AppColors.emergencyRed.withAlpha(15), shape: BoxShape.circle),
                  child: const Icon(Icons.phone_rounded, color: AppColors.emergencyRed, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(number['name']!, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textDark)),
                      Text(number['number']!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(color: AppColors.successGreen, borderRadius: BorderRadius.circular(12)),
                  child: const Text('CALL', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _callNumber(String number) {
    launchUrl(Uri.parse('tel:$number'));
  }

  Widget _buildGuideCard(BuildContext context, Map<String, String> guide) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: ExpansionTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: AppColors.infoBlue.withAlpha(15), shape: BoxShape.circle),
          child: const Icon(Icons.medical_information_rounded, color: AppColors.infoBlue, size: 20),
        ),
        title: Text(guide['title']!, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textDark)),
        iconColor: AppColors.brandPurple,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.bgLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              guide['steps']!,
              style: const TextStyle(fontSize: 13, height: 1.6, color: AppColors.textDark, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
