import 'package:flutter/material.dart';

class AppColors {
  // Screen Backgrounds (Police Dark Theme)
  static const Color bgColor = Color(0xFF0A2540); // Rich True Navy Blue
  
  // Card Backgrounds
  static const Color cardLight = Colors.white; // Massive white cards
  
  // Primary Brand Colors (Police Blue)
  static const Color primaryBlue = Color(0xFF2563EB); // Royal Blue
  static const Color primaryBlueLight = Color(0xFFDBEAFE);
  
  // Police Dark/Navy Colors
  static const Color navyDark = Color(0xFF17365D); // Lighter Navy for elevated elements
  static const Color navyDarker = Color(0xFF061A2E); // Deepest Navy for contrast
  
  // Emergency Red
  static const Color emergencyRed = Color(0xFFEF4444); // Punchy Red
  static const Color emergencyRedBg = Color(0xFFFEE2E2);
  
  // Success / Active Green
  static const Color successGreen = Color(0xFF10B981);
  static const Color successGreenLight = Color(0xFFD1FAE5);
  
  // Warning Amber
  static const Color warningAmber = Color(0xFFF59E0B);
  static const Color warningAmberLight = Color(0xFFFEF3C7);
  
  // Cyan / Tech accents
  static const Color techCyan = Color(0xFF06B6D4);
  static const Color techCyanLight = Color(0xFFCFFAFE);

  // Typography
  static const Color textDark = Color(0xFF0F172A);
  static const Color textLight = Colors.white;
  static const Color textGrey = Color(0xFF64748B); // Slate Grey

  // Gradients
  static const LinearGradient policeGradient = LinearGradient(
    colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)], // Blue
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient emergencyGradient = LinearGradient(
    colors: [Color(0xFFEF4444), Color(0xFFDC2626)], // Red
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient darkNavyGradient = LinearGradient(
    colors: [Color(0xFF17365D), Color(0xFF0A2540)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Shadows (Premium)
  static final List<BoxShadow> softShadow = [
    BoxShadow(color: const Color(0xFF061A2E).withValues(alpha: 0.1), blurRadius: 16, offset: const Offset(0, 4))
  ];
  
  static final List<BoxShadow> premiumCardShadow = [
    BoxShadow(
      color: const Color(0xFF061A2E).withValues(alpha: 0.15),
      blurRadius: 40,
      offset: const Offset(0, 20),
    ),
    BoxShadow(
      color: const Color(0xFF061A2E).withValues(alpha: 0.1),
      blurRadius: 10,
      offset: const Offset(0, 4),
    )
  ];
  
  static final List<BoxShadow> innerGlowBlue = [
    BoxShadow(color: const Color(0xFF2563EB).withValues(alpha: 0.2), blurRadius: 20, spreadRadius: 2)
  ];
  
  static final List<BoxShadow> glowRed = [
    BoxShadow(color: const Color(0xFFEF4444).withValues(alpha: 0.35), blurRadius: 20, spreadRadius: 2)
  ];
  
  static final List<BoxShadow> mapFloatingShadow = [
    BoxShadow(
      color: const Color(0xFF000000).withValues(alpha: 0.3),
      blurRadius: 30,
      offset: const Offset(0, 15),
    )
  ];
}
