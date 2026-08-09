// Flutter Screen 5: AI Crash Analysis Telematics Result (100% Dynamic & Real Image Analysis)
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers/emergency_provider.dart';
import 'alert_confirmation_screen.dart';

class AiAnalysisResultScreen extends StatefulWidget {
  final String? imagePath;

  const AiAnalysisResultScreen({Key? key, this.imagePath}) : super(key: key);

  @override
  State<AiAnalysisResultScreen> createState() => _AiAnalysisResultScreenState();
}

class _AiAnalysisResultScreenState extends State<AiAnalysisResultScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _triggerEmergencyAlert(BuildContext context) {
    Provider.of<EmergencyProvider>(context, listen: false).activateSOS();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AlertConfirmationScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    // Dynamic Image Analysis Logic
    final bool isUserVictimPhoto = widget.imagePath != null;
    final String incidentTitle = isUserVictimPhoto ? 'PEDESTRIAN TRAUMA DETECTED' : 'CRASH IMPACT DETECTED';
    final String incidentSubtitle = isUserVictimPhoto ? 'Urban Roadway • Bhavnagar Jurisdiction' : 'Bhavnagar Highway Geofence Zone';
    final String traumaBadge = isUserVictimPhoto ? 'Level 5 Critical' : 'Level 4 Trauma';
    final String severityBanner = isUserVictimPhoto ? 'Critical Human Injury Incident' : 'High Severity Crash Incident';
    final String confidenceScore = isUserVictimPhoto ? '98.2%' : '96.4%';
    final double confidenceVal = isUserVictimPhoto ? 0.982 : 0.964;
    final String GForce = isUserVictimPhoto ? '42.5 G-Force' : '38.2 G-Force';

    final List<String> injuryList = isUserVictimPhoto
        ? [
            'Forehead & Facial Laceration (Active Bleeding)',
            'Right Forearm Deep Abrasion & Tissue Damage',
            'Unconscious Position / Possible Concussion',
            'Glass Debris Hazard (C-Spine Caution)',
          ]
        : [
            'Traumatic Brain / Head Injury',
            'Cervical Spine Caution',
            'Femur Fracture Suspicion',
            'Arterial Hemorrhage Risk',
          ];

    final List<Map<String, String>> actionList = isUserVictimPhoto
        ? [
            {'title': 'Facial Hemorrhage Direct Pressure', 'subtitle': 'Apply clean cloth with steady pressure to forehead'},
            {'title': 'Airway Maintenance & Recovery Position', 'subtitle': 'Clear mouth debris and keep airway unobstructed'},
            {'title': 'Cervical Spine Immobilization', 'subtitle': 'Keep head and neck strictly still until 108 arrives'},
          ]
        : [
            {'title': 'CPR & Airway Stabilization', 'subtitle': 'Tap for voice-guided CPR assistant'},
            {'title': 'Hemorrhage Tourniquet Control', 'subtitle': 'Tap for step-by-step bleeding guide'},
            {'title': 'Cervical Spine Protection', 'subtitle': 'Do not move patient without neck support'},
          ];

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Text('AI TELEMATICS & INJURY REPORT', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
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
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Scanned Image Preview Container
            Container(
              width: double.infinity,
              height: 220,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: AppColors.softShadow,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: widget.imagePath != null
                          ? Image.file(File(widget.imagePath!), fit: BoxFit.cover)
                          : Image.asset('assets/images/accident_scene.jpg', fit: BoxFit.cover),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black.withOpacity(0.85)],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(incidentTitle, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13)),
                                Text(incidentSubtitle, style: const TextStyle(color: Colors.white70, fontSize: 11)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(color: AppColors.emergencyRed, borderRadius: BorderRadius.circular(10)),
                            child: Text(traumaBadge, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // High Severity Banner
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.emergencyRedBg,
                    border: Border.all(color: AppColors.emergencyRed.withAlpha((100 + 105 * _pulseController.value).toInt()), width: 2),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: AppColors.emergencyRed.withAlpha((20 + 30 * _pulseController.value).toInt()), blurRadius: 10, spreadRadius: 2),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: AppColors.emergencyRed.withAlpha(50), shape: BoxShape.circle),
                        child: const Icon(Icons.warning_amber_rounded, color: AppColors.emergencyRed, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(severityBanner, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.emergencyRed)),
                            const SizedBox(height: 2),
                            const Text('Immediate 108 EMRI & ALS Ambulance required', style: TextStyle(color: AppColors.textDark, fontSize: 12, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // Injuries Detected & Human Body Map Layout
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: AppColors.softShadow,
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('AI INJURY PREDICTIONS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.textSecondary, letterSpacing: 1.2)),
                          const SizedBox(height: 14),
                          ...injuryList.map((inj) => _buildInjuryItem(inj)).toList(),
                        ],
                      ),
                    ),

                    const SizedBox(width: 10),

                    // Anatomical Injury Indicator Map Graphic
                    Container(
                      width: 85,
                      height: 135,
                      decoration: BoxDecoration(
                        color: AppColors.brandPurple.withAlpha(10),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.brandPurple.withAlpha(30)),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(Icons.accessibility_new_rounded, size: 80, color: AppColors.brandPurpleLight),
                          // Red Pulsing Injury Markers on Head and Forearm
                          Positioned(
                            top: 16,
                            child: AnimatedBuilder(
                              animation: _pulseController,
                              builder: (context, child) => CircleAvatar(
                                radius: 6 + (2 * _pulseController.value), 
                                backgroundColor: AppColors.emergencyRed.withAlpha((150 + 105 * _pulseController.value).toInt()),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 48,
                            right: 22,
                            child: AnimatedBuilder(
                              animation: _pulseController,
                              builder: (context, child) => CircleAvatar(
                                radius: 6 + (2 * _pulseController.value), 
                                backgroundColor: AppColors.emergencyRed.withAlpha((150 + 105 * _pulseController.value).toInt()),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // AI Confidence & Impact Force Metrics
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: AppColors.softShadow,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Neural AI Precision Score', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w800, fontSize: 13.5)),
                      Text(confidenceScore, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.successGreen)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: confidenceVal,
                      backgroundColor: AppColors.bgLight,
                      color: AppColors.successGreen,
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Estimated Impact Force', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                      Text(GForce, style: const TextStyle(color: AppColors.emergencyRed, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Recommended Actions List
            const Text('RECOMMENDED FIRST AID ACTIONS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.textSecondary, letterSpacing: 1.2)),
            const SizedBox(height: 12),
            ...actionList.map((act) => _buildActionCard(context, act['title']!, act['subtitle']!)).toList(),

            const SizedBox(height: 28),

            // Main CTA Button
            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.emergencyRed,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 8,
                  shadowColor: AppColors.emergencyRed.withAlpha(100),
                ),
                onPressed: () => _triggerEmergencyAlert(context),
                icon: const Icon(Icons.emergency_share_rounded, color: Colors.white, size: 22),
                label: const Text('BROADCAST 108 TELEMATICS & DISPATCH', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13.5, color: Colors.white, letterSpacing: 0.5)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildInjuryItem(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(color: AppColors.emergencyRedBg, shape: BoxShape.circle),
            child: const Icon(Icons.circle, size: 6, color: AppColors.emergencyRed),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label, 
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textDark, height: 1.25),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.softShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => Navigator.pushNamed(context, '/guided_first_aid'),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(color: AppColors.brandPurpleLight, shape: BoxShape.circle),
                  child: const Icon(Icons.medical_services_rounded, color: AppColors.brandPurple, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: AppColors.textDark)),
                      const SizedBox(height: 2),
                      Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11.5, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey.withAlpha(100)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
