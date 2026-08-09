// Flutter Screen 4 & 5: AI Accident Detection Camera
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../services/ai_accident_scan_service.dart';
import 'ai_analysis_result_screen.dart';

class AiScanScreen extends StatefulWidget {
  const AiScanScreen({Key? key}) : super(key: key);

  @override
  State<AiScanScreen> createState() => _AiScanScreenState();
}

class _AiScanScreenState extends State<AiScanScreen> with SingleTickerProviderStateMixin {
  bool isScanning = false;
  double progress = 0.0;
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

  void startCameraScan() async {
    setState(() {
      isScanning = true;
      progress = 0.2;
    });

    for (int i = 2; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 200));
      if (mounted) {
        setState(() {
          progress = i / 10.0;
        });
      }
    }

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AiAnalysisResultScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    
    return Scaffold(
      backgroundColor: Colors.black, // Camera backdrop is dark
      appBar: AppBar(
        title: const Text('AI SCANNER', style: TextStyle(color: Colors.white, fontSize: 12, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.white.withAlpha(20), shape: BoxShape.circle),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E), // Darker grey for camera feed mockup
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: AppColors.brandPurple.withAlpha(100), width: 2),
                boxShadow: [
                  BoxShadow(color: AppColors.brandPurple.withAlpha(isScanning ? 50 : 20), blurRadius: 30, spreadRadius: 5),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Corner Brackets for Scanner
                  Positioned(top: 20, left: 20, child: _buildScannerCorner(true, true)),
                  Positioned(top: 20, right: 20, child: _buildScannerCorner(true, false)),
                  Positioned(bottom: 20, left: 20, child: _buildScannerCorner(false, true)),
                  Positioned(bottom: 20, right: 20, child: _buildScannerCorner(false, false)),
                  
                  if (isScanning)
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Container(
                          width: double.infinity,
                          height: 4,
                          margin: EdgeInsets.only(top: _pulseController.value * 300 - 150),
                          decoration: BoxDecoration(
                            color: AppColors.brandPurpleLight,
                            boxShadow: [BoxShadow(color: AppColors.brandPurple, blurRadius: 10, spreadRadius: 2)],
                          ),
                        );
                      },
                    ),

                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isScanning)
                        const CircularProgressIndicator(color: AppColors.brandPurpleLight, strokeWidth: 4)
                      else
                        const Icon(Icons.center_focus_strong_rounded, size: 80, color: Colors.white30),
                      
                      const SizedBox(height: 24),
                      Text(
                        isScanning ? 'Analyzing Scene...\n${(progress * 100).toInt()}%' : 'Point camera at the\naccident scene',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Colors.white, height: 1.5, letterSpacing: 0.5),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            decoration: BoxDecoration(
              color: AppColors.bgLight,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  const Text('AI ACCIDENT ANALYSIS', style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                  const SizedBox(height: 12),
                  const Text('Our AI will instantly detect injuries and severity to alert the nearest trauma center automatically.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textDark, fontSize: 14, fontWeight: FontWeight.w600, height: 1.4)),
                  const SizedBox(height: 24),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brandPurple,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        elevation: 8,
                        shadowColor: AppColors.brandPurple.withAlpha(100),
                      ),
                      onPressed: isScanning ? null : startCameraScan,
                      icon: const Icon(Icons.camera_rounded, color: Colors.white, size: 22),
                      label: const Text('Start AI Scan', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.white, letterSpacing: 1)),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildScannerCorner(bool isTop, bool isLeft) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        border: Border(
          top: isTop ? const BorderSide(color: AppColors.brandPurpleLight, width: 4) : BorderSide.none,
          bottom: !isTop ? const BorderSide(color: AppColors.brandPurpleLight, width: 4) : BorderSide.none,
          left: isLeft ? const BorderSide(color: AppColors.brandPurpleLight, width: 4) : BorderSide.none,
          right: !isLeft ? const BorderSide(color: AppColors.brandPurpleLight, width: 4) : BorderSide.none,
        ),
      ),
    );
  }
}
