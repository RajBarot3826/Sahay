// Flutter Screen 9: Visual Video & Voice Guided First Aid Assistant (Clean & Non-Truncated UI)
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_colors.dart';
import 'cpr_voice_guide_screen.dart';

class GuidedFirstAidScreen extends StatefulWidget {
  const GuidedFirstAidScreen({Key? key}) : super(key: key);

  @override
  State<GuidedFirstAidScreen> createState() => _GuidedFirstAidScreenState();
}

class _GuidedFirstAidScreenState extends State<GuidedFirstAidScreen> with TickerProviderStateMixin {
  int currentStepIndex = 0;
  bool isPlayingVideo = true;
  double videoProgress = 0.35;
  int videoSeconds = 15;
  Timer? _videoTimer;
  Timer? _metronomeTimer;
  int cprBeatCount = 0;
  final FlutterTts flutterTts = FlutterTts();
  late AnimationController _pulseController;

  final List<Map<String, dynamic>> _firstAidSteps = [
    {
      'stepNum': 1,
      'title': 'Check Victim Response',
      'instruction': 'Tap and shake the shoulders gently and ask loudly "Are you okay?"',
      'gujaratiVoice': '🔊 "દર્દીનું માથું સહેજ પાછળ તરફ નમવો જેથી શ્વાસનળી ખુલ્લી રહે"',
      'icon': Icons.front_hand_rounded,
      'imageAsset': 'assets/images/first_aid_check.jpg',
      'badgeColor': AppColors.infoBlue,
    },
    {
      'stepNum': 2,
      'title': 'Clear Airway & Position Head',
      'instruction': 'Tilt head back gently with chin lifted to open the respiratory airway.',
      'gujaratiVoice': '🔊 "હવા માટે શ્વાસનળી ખુલ્લી રાખો, માથું પાછળ તરફ કરો"',
      'icon': Icons.air_rounded,
      'imageAsset': 'assets/images/first_aid_check.jpg',
      'badgeColor': AppColors.brandPurple,
    },
    {
      'stepNum': 3,
      'title': 'Check Breathing & Pulse',
      'instruction': 'Look at chest movement for 10 seconds. Listen for normal breathing sounds.',
      'gujaratiVoice': '🔊 "૧૦ સેકન્ડ માટે છાતીનું હલનચલન અને શ્વાસ તપાસો"',
      'icon': Icons.favorite_rounded,
      'imageAsset': 'assets/images/cpr_first_aid.jpg',
      'badgeColor': AppColors.warningAmber,
    },
    {
      'stepNum': 4,
      'title': 'CPR Chest Compressions',
      'instruction': 'Push hard and fast in the center of chest at 100-120 beats per minute rhythm.',
      'gujaratiVoice': '🔊 "છાતીની મધ્યમાં ૧૦૦ થી ૧૨૦ પ્રતિ મિનિટ ઝડપે દબાણ આપો"',
      'icon': Icons.health_and_safety_rounded,
      'imageAsset': 'assets/images/cpr_first_aid.jpg',
      'badgeColor': AppColors.emergencyRed,
    },
    {
      'stepNum': 5,
      'title': 'Apply Pressure Bandage',
      'instruction': 'For heavy bleeding, apply firm direct pressure with clean cloth or tourniquet.',
      'gujaratiVoice': '🔊 "લોહી વહેતું અટકાવવા કપડાથી મજબૂત દબાણ આપો"',
      'icon': Icons.medical_services_rounded,
      'imageAsset': 'assets/images/accident_scene.jpg',
      'badgeColor': AppColors.emergencyRed,
    },
    {
      'stepNum': 6,
      'title': 'Recovery Position',
      'instruction': 'Roll victim onto their side with head resting on arm to protect airway.',
      'gujaratiVoice': '🔊 "દર્દીને એક તરફ નમાવી રિકવરી પોઝિશનમાં રાખો"',
      'icon': Icons.accessibility_new_rounded,
      'imageAsset': 'assets/images/first_aid_check.jpg',
      'badgeColor': AppColors.successGreen,
    },
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    )..repeat(reverse: true);

    _startVideoPlayback();
    _startVoiceGuidance();
  }

  void _startVideoPlayback() {
    _videoTimer?.cancel();
    _videoTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && isPlayingVideo) {
        setState(() {
          videoSeconds = (videoSeconds + 1) % 46;
          videoProgress = videoSeconds / 45.0;
          if (currentStepIndex == 3) {
            cprBeatCount = (cprBeatCount + 1) % 30;
          }
        });
      }
    });
  }

  Future<void> _startVoiceGuidance() async {
    try {
      await flutterTts.setLanguage("gu-IN");
      await flutterTts.setSpeechRate(0.5);
      final currentStep = _firstAidSteps[currentStepIndex];
      await flutterTts.speak(currentStep['instruction']);
    } catch (_) {}
  }

  @override
  void dispose() {
    _videoTimer?.cancel();
    _metronomeTimer?.cancel();
    _pulseController.dispose();
    flutterTts.stop();
    super.dispose();
  }

  void _nextStep() {
    if (currentStepIndex < _firstAidSteps.length - 1) {
      setState(() {
        currentStepIndex++;
        videoSeconds = 0;
        videoProgress = 0.0;
      });
      _startVoiceGuidance();
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CprVoiceGuideScreen()),
      );
    }
  }

  void _previousStep() {
    if (currentStepIndex > 0) {
      setState(() {
        currentStepIndex--;
        videoSeconds = 0;
        videoProgress = 0.0;
      });
      _startVoiceGuidance();
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    final step = _firstAidSteps[currentStepIndex];

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Text(
          'FIRST AID ASSISTANT',
          style: TextStyle(color: AppColors.textDark, fontSize: 13, letterSpacing: 1.2, fontWeight: FontWeight.bold),
        ),
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
        actions: [
          Container(
            margin: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: AppColors.glowPurple,
            ),
            child: IconButton(
              icon: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 20),
              onPressed: () => Navigator.pushNamed(context, '/ai_doctor'),
              tooltip: 'Multimodal AI Doctor Assistant',
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Step Counter Pill
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: (step['badgeColor'] as Color? ?? AppColors.brandPurple).withAlpha(25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'STEP ${step['stepNum']} OF ${_firstAidSteps.length}',
                      style: TextStyle(color: (step['badgeColor'] as Color? ?? AppColors.brandPurple), fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.2),
                    ),
                  ),
                  if (step['stepNum'] == 4)
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.emergencyRed,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(color: AppColors.emergencyRed.withOpacity(0.6), blurRadius: 8 * _pulseController.value),
                            ],
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.favorite_rounded, color: Colors.white, size: 12),
                              SizedBox(width: 4),
                              Text('110 BPM CPR RHYTHM', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                step['title'],
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.textDark, letterSpacing: -0.5),
              ),
              const SizedBox(height: 14),

              // Visual Reference Image Container
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: AppColors.softShadow,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned.fill(
                          child: Image.asset(
                            step['imageAsset'],
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, err, stack) => Container(
                              color: AppColors.brandPurple.withAlpha(20),
                              child: const Icon(Icons.medical_services_rounded, size: 60, color: AppColors.brandPurple),
                            ),
                          ),
                        ),

                        // CPR Beat Overlay Badge (Step 4)
                        if (step['stepNum'] == 4)
                          Positioned(
                            top: 14,
                            child: AnimatedBuilder(
                              animation: _pulseController,
                              builder: (context, child) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.emergencyRed,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: AppColors.glowRed,
                                  ),
                                  child: Text(
                                    'COMPRESS NOW! (${cprBeatCount + 1}/30)',
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12),
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Step Guidance Text Box
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: AppColors.softShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: (step['badgeColor'] as Color? ?? AppColors.brandPurple).withAlpha(20), shape: BoxShape.circle),
                          child: Icon((step['icon'] as IconData? ?? Icons.medical_services_rounded), color: (step['badgeColor'] as Color? ?? AppColors.brandPurple), size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            step['instruction'],
                            style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.textDark, height: 1.35),
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                      child: Divider(height: 1, color: Colors.black12),
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(color: AppColors.brandPurpleLight, shape: BoxShape.circle),
                          child: const Icon(Icons.volume_up_rounded, color: AppColors.brandPurple, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            step['gujaratiVoice'],
                            style: const TextStyle(fontSize: 12, color: AppColors.brandPurple, fontWeight: FontWeight.bold, height: 1.35),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Prev / Next Navigation Buttons
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                          side: const BorderSide(color: AppColors.textSecondary, width: 1.5),
                        ),
                        onPressed: _previousStep,
                        child: const Text('Previous', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.textDark)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.brandPurple,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                          elevation: 6,
                          shadowColor: AppColors.brandPurple.withAlpha(100),
                        ),
                        onPressed: _nextStep,
                        child: Text(
                          currentStepIndex == _firstAidSteps.length - 1 ? 'Launch CPR Mode' : 'Next Step',
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
