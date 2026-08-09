// Flutter Screen: Futuristic High-Level Multimodal AI Doctor HUD & Scenario Assistant
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../constants/app_colors.dart';
import '../services/ai_triage_service.dart';

class LiveAiFirstAidDoctorScreen extends StatefulWidget {
  const LiveAiFirstAidDoctorScreen({Key? key}) : super(key: key);

  @override
  State<LiveAiFirstAidDoctorScreen> createState() => _LiveAiFirstAidDoctorScreenState();
}

class _LiveAiFirstAidDoctorScreenState extends State<LiveAiFirstAidDoctorScreen> with TickerProviderStateMixin {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraReady = false;
  
  bool _isListening = false;
  bool _isAnalyzing = false;
  
  String _selectedLanguage = 'English'; // Default to English
  
  final FlutterTts _flutterTts = FlutterTts();
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  final AiTriageService _triageService = AiTriageService();

  late AnimationController _scannerController;
  late AnimationController _pulseController;

  late List<Map<String, String>> _chatHistory;

  String _currentSpokenText = "";

  @override
  void initState() {
    super.initState();
    _scannerController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))..repeat(reverse: true);
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 700))..repeat(reverse: true);

    _chatHistory = [];
    
    _initCamera();
    _initTts();
    _initStt();
    
    _startConversation();
  }
  
  Future<void> _startConversation() async {
    await _triageService.initChat();
    String initialQ = _triageService.getInitialQuestion(_selectedLanguage);
    setState(() {
      _chatHistory = [
        {
          'sender': 'ai',
          'text': initialQ,
        }
      ];
    });
    _speakText(initialQ);
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        _cameraController = CameraController(_cameras![0], ResolutionPreset.medium, enableAudio: false);
        await _cameraController!.initialize();
        if (mounted) setState(() => _isCameraReady = true);
      }
    } catch (e) {
      print("AI Doctor Camera init: $e");
    }
  }

  Future<void> _initTts() async {
    try {
      await _setTtsLanguage();
      await _flutterTts.setSpeechRate(0.5);
    } catch (_) {}
  }
  
  Future<void> _setTtsLanguage() async {
    if (_selectedLanguage == 'Gujarati') {
      await _flutterTts.setLanguage("gu-IN");
    } else if (_selectedLanguage == 'Hindi') {
      await _flutterTts.setLanguage("hi-IN");
    } else {
      await _flutterTts.setLanguage("en-US");
    }
  }

  Future<void> _initStt() async {
    try {
      await _speechToText.initialize(
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
             if(_isListening) {
                setState(() => _isListening = false);
                if (_currentSpokenText.isNotEmpty) {
                   _askAiDoctor(_currentSpokenText);
                   _currentSpokenText = "";
                }
             }
          }
        },
        onError: (error) {
           setState(() => _isListening = false);
        }
      );
    } catch (e) {
      print("STT Init Error: $e");
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _scannerController.dispose();
    _pulseController.dispose();
    _flutterTts.stop();
    _speechToText.stop();
    super.dispose();
  }

  void _speakText(String text) async {
    try {
      await _setTtsLanguage();
      await _flutterTts.speak(text);
    } catch (_) {}
  }

  Future<void> _askAiDoctor(String userQuestion) async {
    if (userQuestion.trim().isEmpty) return;
    
    setState(() {
      _chatHistory.add({'sender': 'user', 'text': userQuestion});
      _isAnalyzing = true;
    });

    final aiResponse = await _triageService.sendMessage(userQuestion);

    if (!mounted) return;

    setState(() {
      _isAnalyzing = false;
      _chatHistory.add({
        'sender': 'ai',
        'text': aiResponse,
      });
    });

    _speakText(aiResponse);
  }
  
  void _listen() async {
    if (!_isListening) {
      bool available = await _speechToText.initialize();
      if (available) {
        setState(() => _isListening = true);
        String localeId = 'en_US';
        if (_selectedLanguage == 'Gujarati') localeId = 'gu_IN';
        if (_selectedLanguage == 'Hindi') localeId = 'hi_IN';
        
        _speechToText.listen(
          onResult: (result) {
            setState(() {
              _currentSpokenText = result.recognizedWords;
            });
            if (result.finalResult) {
               setState(() => _isListening = false);
               _askAiDoctor(result.recognizedWords);
               _currentSpokenText = "";
            }
          },
          localeId: localeId,
        );
      }
    } else {
      setState(() => _isListening = false);
      _speechToText.stop();
      if (_currentSpokenText.isNotEmpty) {
        _askAiDoctor(_currentSpokenText);
        _currentSpokenText = "";
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    return Scaffold(
      backgroundColor: const Color(0xFF0B071B),
      appBar: AppBar(
        title: const Text(
          'AI TRIAGE DOCTOR',
          style: TextStyle(color: Colors.white, fontSize: 13, letterSpacing: 1.5, fontWeight: FontWeight.w900),
        ),
        backgroundColor: const Color(0xFF140D2B),
        elevation: 0,
        centerTitle: true,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), shape: BoxShape.circle),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.translate_rounded, color: Colors.white),
            onPressed: _showLanguageSelector,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Emergency Info Panel
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.emergencyRed.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.emergencyRed.withOpacity(0.5)),
              ),
              child: Row(
                children: [
                   const Icon(Icons.warning_amber_rounded, color: AppColors.emergencyRed, size: 28),
                   const SizedBox(width: 12),
                   Expanded(
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Text('TRIAGE ACTIVE', style: TextStyle(color: AppColors.emergencyRed, fontSize: 12, fontWeight: FontWeight.bold)),
                         const SizedBox(height: 4),
                         const Text('Follow AI instructions carefully. Prioritize safety.', style: TextStyle(color: Colors.white, fontSize: 11)),
                       ]
                     )
                   ),
                   ElevatedButton(
                     style: ElevatedButton.styleFrom(
                       backgroundColor: AppColors.emergencyRed,
                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)
                     ),
                     onPressed: () {},
                     child: const Text('CALL 108', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))
                   )
                ],
              ),
            ),
            
            // Futuristic Live Vision Camera HUD Viewfinder Container
            Container(
              height: 180,
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.brandPurple, width: 2),
                boxShadow: [
                  BoxShadow(color: AppColors.brandPurple.withOpacity(0.35), blurRadius: 14, spreadRadius: 2),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (_isCameraReady && _cameraController != null)
                      Positioned.fill(child: CameraPreview(_cameraController!))
                    else
                      Positioned.fill(
                        child: Container(color: const Color(0xFF150D2A)),
                      ),

                    // Cyber HUD Scan Line Animation
                    AnimatedBuilder(
                      animation: _scannerController,
                      builder: (context, child) {
                        return Positioned(
                          top: 180 * _scannerController.value,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 2,
                            decoration: BoxDecoration(
                              color: AppColors.brandPurple,
                              boxShadow: [
                                BoxShadow(color: AppColors.brandPurple, blurRadius: 8, spreadRadius: 2),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    // Top Left AI Vision Active Pill
                    Positioned(
                      top: 10,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.75),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.successGreen.withOpacity(0.8)),
                        ),
                        child: const Row(
                          children: [
                            CircleAvatar(radius: 4, backgroundColor: AppColors.successGreen),
                            SizedBox(width: 6),
                            Text('GEMINI VISION HUD ACTIVE', style: TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w900)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // AI Doctor Diagnostic Chat Stream
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: _chatHistory.length,
                itemBuilder: (context, index) {
                  final msg = _chatHistory[index];
                  final isUser = msg['sender'] == 'user';
                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
                      decoration: BoxDecoration(
                        color: isUser ? AppColors.brandPurple : const Color(0xFF1D133B),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isUser ? AppColors.brandPurpleLight : Colors.white12),
                        boxShadow: isUser ? AppColors.glowPurple : [],
                      ),
                      child: Text(
                        msg['text']!,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13.5,
                          height: 1.4,
                          fontWeight: isUser ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            if (_isAnalyzing)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: AppColors.brandPurpleLight, strokeWidth: 2)),
                    SizedBox(width: 8),
                    Text('Gemini AI is analyzing...', style: TextStyle(color: Colors.white70, fontSize: 11.5, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),

            // Quick Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                   _buildQuickAction('Yes', Colors.green),
                   _buildQuickAction('No', Colors.redAccent),
                   _buildQuickAction("I'm not sure", Colors.grey),
                ]
              )
            ),

            // Futuristic Audio Mic Controls Bottom Bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFF140D2B),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Text(
                        _isListening ? (_currentSpokenText.isNotEmpty ? _currentSpokenText : 'Listening...') : 'Tap mic and speak...',
                        style: TextStyle(
                          color: _isListening ? AppColors.successGreen : Colors.white54,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _listen,
                    child: AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            gradient: _isListening ? AppColors.emergencyGradient : AppColors.primaryGradient,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: _isListening ? AppColors.emergencyRed.withOpacity(0.8) : AppColors.brandPurple.withOpacity(0.8),
                                blurRadius: 12 + (8 * _pulseController.value),
                                spreadRadius: 2 * _pulseController.value,
                              )
                            ],
                          ),
                          child: Icon(
                            _isListening ? Icons.graphic_eq_rounded : Icons.mic_rounded,
                            color: Colors.white,
                            size: 26,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildQuickAction(String text, Color color) {
    return GestureDetector(
      onTap: () {
         _askAiDoctor(text);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.5))
        ),
        child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12))
      )
    );
  }

  void _showLanguageSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1138),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Language', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.language_rounded, color: AppColors.brandPurpleLight),
              title: const Text('English (US)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              trailing: _selectedLanguage == 'English' ? const Icon(Icons.check_circle_rounded, color: AppColors.successGreen) : null,
              onTap: () {
                setState(() { _selectedLanguage = 'English'; _startConversation(); });
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.language_rounded, color: AppColors.brandPurpleLight),
              title: const Text('ગુજરાતી (Gujarati)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              trailing: _selectedLanguage == 'Gujarati' ? const Icon(Icons.check_circle_rounded, color: AppColors.successGreen) : null,
              onTap: () {
                setState(() { _selectedLanguage = 'Gujarati'; _startConversation(); });
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.language_rounded, color: AppColors.brandPurpleLight),
              title: const Text('हिंदी (Hindi)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              trailing: _selectedLanguage == 'Hindi' ? const Icon(Icons.check_circle_rounded, color: AppColors.successGreen) : null,
              onTap: () {
                setState(() { _selectedLanguage = 'Hindi'; _startConversation(); });
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }
}
