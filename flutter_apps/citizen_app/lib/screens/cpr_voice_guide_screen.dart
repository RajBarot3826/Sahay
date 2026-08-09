// Flutter Screen 10: CPR Voice Guide & Metronome (Exact Match to Image 1 Screen 10)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../services/cpr_metronome_service.dart';

class CprVoiceGuideScreen extends StatefulWidget {
  const CprVoiceGuideScreen({Key? key}) : super(key: key);

  @override
  State<CprVoiceGuideScreen> createState() => _CprVoiceGuideScreenState();
}

class _CprVoiceGuideScreenState extends State<CprVoiceGuideScreen> with SingleTickerProviderStateMixin {
  final _metronomeService = CprMetronomeService();
  int compressionCount = 28;
  bool isBeating = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500))..repeat(reverse: true);
  }

  void toggleMetronome() {
    if (isBeating) {
      _metronomeService.stopMetronome();
      setState(() => isBeating = false);
    } else {
      _metronomeService.startMetronome(onBeat: (count) {
        if (mounted) setState(() => compressionCount = count);
      });
      setState(() => isBeating = true);
    }
  }

  @override
  void dispose() {
    _metronomeService.stopMetronome();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Text('CPR VOICE GUIDE', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
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
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: AppColors.softShadow),
            child: IconButton(
              icon: const Icon(Icons.info_outline_rounded, color: AppColors.textDark, size: 18),
              onPressed: () { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Action executed successfully'))); },
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.successGreen.withAlpha(20),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('Good! Now Start CPR', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: AppColors.successGreen)),
              ),
              const SizedBox(height: 40),

              // Large Compression Ring Visualizer
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    height: 220,
                    width: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(
                        color: isBeating ? AppColors.emergencyRed : AppColors.brandPurpleLight,
                        width: 8 + (isBeating ? (_pulseController.value * 4) : 0),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (isBeating ? AppColors.emergencyRed : AppColors.brandPurple).withAlpha(isBeating ? (50 + 50 * _pulseController.value).toInt() : 20),
                          blurRadius: isBeating ? 40 : 20,
                          spreadRadius: isBeating ? 10 * _pulseController.value : 0,
                        )
                      ],
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$compressionCount',
                            style: TextStyle(
                              fontSize: 64, 
                              fontWeight: FontWeight.w900, 
                              color: isBeating ? AppColors.emergencyRed : AppColors.textDark,
                              height: 1.1,
                            ),
                          ),
                          const Text('Compressions', style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),

              // ECG Waveform Visualizer
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.monitor_heart_rounded, color: AppColors.emergencyRed, size: 48),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Push hard and fast\nat the center of chest',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.textDark, height: 1.3),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Controls: Language Selector & Metronome Audio Trigger
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: AppColors.softShadow,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.bgLight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.language_rounded, size: 18, color: AppColors.brandPurple),
                          SizedBox(width: 8),
                          Text('Gujarati', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                          SizedBox(width: 4),
                          Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: AppColors.textSecondary),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: toggleMetronome,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isBeating ? AppColors.emergencyRed : AppColors.brandPurple,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: (isBeating ? AppColors.emergencyRed : AppColors.brandPurple).withAlpha(100), blurRadius: 10, spreadRadius: 2)
                          ]
                        ),
                        child: Icon(isBeating ? Icons.volume_up_rounded : Icons.play_arrow_rounded, color: Colors.white, size: 28),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
