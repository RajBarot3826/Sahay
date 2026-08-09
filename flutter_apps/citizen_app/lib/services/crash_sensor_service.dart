import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';

enum CrashSensitivity { low, medium, high }

class _TimedEvent {
  final AccelerometerEvent event;
  final DateTime time;
  _TimedEvent(this.event, this.time);
}

class CrashSensorService {
  StreamController<bool>? _crashStreamController;
  StreamSubscription<AccelerometerEvent>? _accelSubscription;
  
  bool _isMonitoring = false;
  
  final List<_TimedEvent> _window = [];
  final Duration _windowDuration = const Duration(milliseconds: 500);
  
  DateTime? _lastCrashTime;

  CrashSensitivity sensitivity = CrashSensitivity.medium;

  double get _gForceThreshold {
    switch (sensitivity) {
      case CrashSensitivity.low:
        return 6.0;
      case CrashSensitivity.medium:
        return 4.0;
      case CrashSensitivity.high:
        return 3.0;
    }
  }

  Stream<bool> get onCrashDetected {
    _crashStreamController ??= StreamController<bool>.broadcast();
    return _crashStreamController!.stream;
  }

  void startMonitoring() {
    if (_isMonitoring) return;
    _isMonitoring = true;
    _window.clear();
    
    _accelSubscription = accelerometerEventStream().listen((AccelerometerEvent event) {
      _processAccelerometerEvent(event);
    });
  }

  void stopMonitoring() {
    if (!_isMonitoring) return;
    _isMonitoring = false;
    _accelSubscription?.cancel();
    _accelSubscription = null;
    _window.clear();
  }

  void _processAccelerometerEvent(AccelerometerEvent event) {
    final now = DateTime.now();

    // Debounce: Ignore sensor data for 30 seconds after detecting a crash
    if (_lastCrashTime != null && now.difference(_lastCrashTime!).inSeconds < 30) {
      return;
    }

    _window.add(_TimedEvent(event, now));
    
    // Remove old events outside the window
    _window.removeWhere((e) => now.difference(e.time) > _windowDuration);
    
    // Calculate G-force magnitude
    double magnitude = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
    double gForce = magnitude / 9.8;
    
    // Subtract gravity baseline (~1G) to get net acceleration
    double netGForce = (gForce - 1.0).abs();
    
    // Check if the current net G-force exceeds threshold
    if (netGForce > _gForceThreshold) {
      // Look for sustained impact in the sliding window to avoid drop false-positives
      var highGEvents = _window.where((e) {
        double m = sqrt(e.event.x * e.event.x + e.event.y * e.event.y + e.event.z * e.event.z);
        return (m / 9.8 - 1.0).abs() > _gForceThreshold;
      }).toList();
      
      // A car crash impact lasts typically >50ms. A phone drop spike is very brief.
      // If we see high G-forces sustained over at least 30ms or multiple samples, it's likely a real crash.
      if (highGEvents.length >= 3) {
        final duration = highGEvents.last.time.difference(highGEvents.first.time);
        if (duration.inMilliseconds >= 30) {
          _triggerCrash();
        }
      }
    }
  }

  void _triggerCrash() {
    _lastCrashTime = DateTime.now();
    _crashStreamController?.add(true);
    _window.clear(); // Clear window to avoid multiple rapid triggers
  }

  void simulateImpact() {
    _triggerCrash();
  }

  void dispose() {
    stopMonitoring();
    _accelSubscription?.cancel();
    _accelSubscription = null;
    _crashStreamController?.close();
  }
}
