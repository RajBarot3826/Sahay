import 'dart:async';
import 'package:flutter_tts/flutter_tts.dart';

class CprMetronomeService {
  static const int targetBpm = 100;
  static const int intervalMs = 600; // 60,000ms / 100 BPM = 600ms per beat
  Timer? _timer;
  bool _isPlaying = false;
  int _compressionCount = 0;
  final FlutterTts _flutterTts = FlutterTts();

  bool get isPlaying => _isPlaying;
  int get compressionCount => _compressionCount;

  CprMetronomeService() {
    _initTts();
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.8); // Fast enough to keep up with 100bpm
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  void startMetronome({required Function(int count) onBeat}) {
    if (_isPlaying) return;
    _isPlaying = true;
    _compressionCount = 0;

    // Speak initial instruction
    _flutterTts.speak("Start compressions");

    _timer = Timer.periodic(const Duration(milliseconds: intervalMs), (timer) {
      _compressionCount++;
      onBeat(_compressionCount);
      
      // Speak the number every 10 beats, otherwise just a short tick sound
      if (_compressionCount % 10 == 0) {
        _flutterTts.speak(_compressionCount.toString());
      } else {
        // We use TTS to speak a short tick
        _flutterTts.speak("tick");
      }
    });
  }

  void stopMetronome() {
    _isPlaying = false;
    _timer?.cancel();
    _flutterTts.stop();
  }

  void resetCount() {
    _compressionCount = 0;
  }
}
