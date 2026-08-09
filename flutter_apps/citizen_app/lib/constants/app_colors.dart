// Exact Match Color System — Matching Image 1 Mockup Light/Dark Themes
import 'package:flutter/material.dart';

class AppColors {
  // Screen Backgrounds (Exact Match to Image 1)
  static const Color bgLight = Color(0xFFF5EFFB); // Light Lavender Background for Screens 2-12, 14-24
  static const Color bgDark = Color(0xFF1B1135);  // Dark Purple Background for Screens 1, 4, 13
  
  // Card Backgrounds
  static const Color cardLight = Colors.white;
  static const Color cardPurple = Color(0xFF261845);
  static const Color cardPurpleDark = Color(0xFF1B1135);
  static const Color bgCardDark = Color(0xFF261845);

  // Primary Brand Colors (Image 1 Palette)
  static const Color brandPurple = Color(0xFF8C52FF); // Vivid Purple Buttons & Headers
  static const Color primaryPurple = Color(0xFF8C52FF);
  static const Color brandPurpleLight = Color(0xFFEADBFF);
  static const Color primaryPurpleLight = Color(0xFFEADBFF);
  
  // Emergency Red & Green (Image 1 Palette)
  static const Color emergencyRed = Color(0xFFFF3B56); // Emergency Red
  static const Color emergencyRedBg = Color(0xFFFFEAEF);
  
  static const Color successGreen = Color(0xFF10B981); // Immunity & ETA Green
  static const Color successGreenBg = Color(0xFFD1FAE5);
  
  static const Color warningAmber = Color(0xFFF59E0B);
  static const Color infoBlue = Color(0xFF38BDF8);

  // Typography
  static const Color textDark = Color(0xFF1F1535); // Dark text on light cards
  static const Color textLight = Colors.white;
  static const Color textSecondary = Color(0xFF756A8A);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF8C52FF), Color(0xFF6B26FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient emergencyGradient = LinearGradient(
    colors: [Color(0xFFFF3B56), Color(0xFFE01A37)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static List<BoxShadow> softShadow = [
    BoxShadow(color: const Color(0xFF8C52FF).withOpacity(0.08), blurRadius: 16, offset: const Offset(0, 4))
  ];
  static List<BoxShadow> glowPurple = [
    BoxShadow(color: const Color(0xFF8C52FF).withOpacity(0.35), blurRadius: 20, spreadRadius: 2)
  ];
  static List<BoxShadow> glowRed = [
    BoxShadow(color: const Color(0xFFFF3B56).withOpacity(0.35), blurRadius: 20, spreadRadius: 2)
  ];
}
