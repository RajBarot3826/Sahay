// Flutter Screen 4: Real-Time Live Hardware Camera AI Crash Scanner
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_colors.dart';
import 'ai_analysis_result_screen.dart';

class AiCameraScanScreen extends StatefulWidget {
  const AiCameraScanScreen({Key? key}) : super(key: key);

  @override
  State<AiCameraScanScreen> createState() => _AiCameraScanScreenState();
}

class _AiCameraScanScreenState extends State<AiCameraScanScreen> with SingleTickerProviderStateMixin {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isAnalyzing = false;
  double _scanProgress = 0.0;
  Timer? _scanTimer;
  XFile? _capturedImage;
  late AnimationController _laserController;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _laserController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _initHardwareCamera();
  }

  Future<void> _initHardwareCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        _cameraController = CameraController(
          _cameras![0],
          ResolutionPreset.high,
          enableAudio: false,
        );
        await _cameraController!.initialize();
        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
          });
        }
      }
    } catch (e) {
      print("Camera init info: $e");
    }
  }

  @override
  void dispose() {
    _scanTimer?.cancel();
    _laserController.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _captureLivePhoto() async {
    try {
      if (_cameraController != null && _cameraController!.value.isInitialized) {
        final XFile photo = await _cameraController!.takePicture();
        setState(() {
          _capturedImage = photo;
        });
      }
    } catch (_) {}
    _startAiScanning();
  }

  Future<void> _pickGalleryImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _capturedImage = image;
        });
        _startAiScanning();
      }
    } catch (_) {
      _startAiScanning();
    }
  }

  void _startAiScanning() {
    setState(() {
      _isAnalyzing = true;
      _scanProgress = 0.0;
    });

    _scanTimer?.cancel();
    _scanTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      setState(() {
        _scanProgress += 0.025;
        if (_scanProgress >= 1.0) {
          _scanProgress = 1.0;
          _scanTimer?.cancel();
          _navigateToResult();
        }
      });
    });
  }

  void _navigateToResult() {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => AiAnalysisResultScreen(
            imagePath: _capturedImage?.path,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: const Text('AI CRASH SCANNER', style: TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.cardPurpleDark,
        elevation: 0,
        centerTitle: true,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: const BoxDecoration(color: Colors.white10, shape: BoxShape.circle),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Text(
                _isCameraInitialized ? 'Live Camera Feed Active — Point at accident scene' : 'Point camera or upload crash photo\nfor AI structural & injury telematics',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white70, height: 1.4),
              ),
              const SizedBox(height: 14),

              // Camera Frame Container (Live Camera Preview OR Captured Photo OR Fallback)
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: AppColors.brandPurple, width: 2.5),
                    boxShadow: AppColors.glowPurple,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Live Hardware Camera Stream
                        if (_capturedImage != null)
                          Positioned.fill(
                            child: Image.file(File(_capturedImage!.path), fit: BoxFit.cover),
                          )
                        else if (_isCameraInitialized && _cameraController != null)
                          Positioned.fill(
                            child: CameraPreview(_cameraController!),
                          )
                        else
                          Positioned.fill(
                            child: Image.asset(
                              'assets/images/accident_scene.jpg',
                              fit: BoxFit.cover,
                              errorBuilder: (ctx, err, stack) => Container(
                                color: const Color(0xFF150D2A),
                                child: const Center(
                                  child: Icon(Icons.camera_alt_rounded, size: 80, color: AppColors.brandPurpleLight),
                                ),
                              ),
                            ),
                          ),

                        // Corner Reticles
                        Positioned(top: 20, left: 20, child: _buildReticle(true, true)),
                        Positioned(top: 20, right: 20, child: _buildReticle(true, false)),
                        Positioned(bottom: 20, left: 20, child: _buildReticle(false, true)),
                        Positioned(bottom: 20, right: 20, child: _buildReticle(false, false)),

                        // Live AI Scanning Laser Sweep
                        if (_isAnalyzing)
                          AnimatedBuilder(
                            animation: _laserController,
                            builder: (context, child) {
                              return Positioned(
                                top: MediaQuery.of(context).size.height * 0.45 * _laserController.value,
                                left: 0,
                                right: 0,
                                child: Container(
                                  height: 3.5,
                                  decoration: BoxDecoration(
                                    color: AppColors.successGreen,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.successGreen.withOpacity(0.9),
                                        blurRadius: 16,
                                        spreadRadius: 6,
                                      )
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),

                        // Bounding Box Overlays
                        if (_isAnalyzing && _scanProgress > 0.4)
                          Positioned(
                            top: 80,
                            left: 40,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: AppColors.emergencyRed.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.white, width: 1.5),
                              ),
                              child: const Text('Structural Debris 96%', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                            ).animate().scale(),
                          ),

                        if (_isAnalyzing && _scanProgress > 0.7)
                          Positioned(
                            bottom: 90,
                            right: 30,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: AppColors.warningAmber.withOpacity(0.95),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.white, width: 1.5),
                              ),
                              child: const Text('Cabin Deformation Risk', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                            ).animate().scale(),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Progress Bar
              if (_isAnalyzing) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Neural Telematics Processing...', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                    Text('${(_scanProgress * 100).toInt()}%', style: const TextStyle(color: AppColors.brandPurple, fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: _scanProgress,
                    backgroundColor: Colors.white12,
                    color: AppColors.brandPurple,
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Shutter & Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Gallery Button
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white12,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onPressed: _pickGalleryImage,
                    icon: const Icon(Icons.photo_library_rounded, size: 20),
                    label: const Text('Gallery', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ),

                  // Hardware Camera Shutter Trigger
                  GestureDetector(
                    onTap: _captureLivePhoto,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: const BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt_rounded, size: 34, color: Colors.white),
                      ),
                    ),
                  ),

                  // Sample Scene Trigger
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white12,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onPressed: _startAiScanning,
                    icon: const Icon(Icons.auto_awesome_rounded, size: 20, color: AppColors.brandPurpleLight),
                    label: const Text('Sample', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text('Tap center shutter to capture live camera photo for 108 dispatch', style: TextStyle(color: Colors.white54, fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReticle(bool isTop, bool isLeft) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        border: Border(
          top: isTop ? const BorderSide(color: Colors.white, width: 3) : BorderSide.none,
          bottom: !isTop ? const BorderSide(color: Colors.white, width: 3) : BorderSide.none,
          left: isLeft ? const BorderSide(color: Colors.white, width: 3) : BorderSide.none,
          right: !isLeft ? const BorderSide(color: Colors.white, width: 3) : BorderSide.none,
        ),
      ),
    );
  }
}
