import 'package:flutter/material.dart';

class AppColors {
  // Main Citizen App Aesthetic Colors
  static const Color bgColor = Color(0xFFF8F7FC); // Very light grey with purple/pink tint
  static const Color primaryPurple = Color(0xFF8247FF); // Vibrant primary purple
  static const Color primaryPurpleDark = Color(0xFF6B21A8); // Deep rich purple for gradients
  static const Color primaryPurpleLight = Color(0xFFF3F0FF); // Light background for inputs/cards
  
  static const Color textDark = Color(0xFF0F172A); // Almost black for primary titles
  static const Color textGrey = Color(0xFF64748B); // Medium grey for subtitles

  static const Color emergencyRed = Color(0xFFFF3B4C); // Punchy Red for final/emergency actions
  static const Color emergencyRedDark = Color(0xFFE11D48);

  static const Color successGreen = Color(0xFF22C55E); // Green for toggles/success
  static const Color successGreenLight = Color(0xFFE8FDF0);

  // Fallbacks & Aliases (to prevent breaking other screens immediately)
  static const Color backgroundWhite = bgColor;
  static const Color cardGrey = primaryPurpleLight;
  static const Color textLight = textGrey;
  static const Color bgLight = bgColor; 
  static const Color bgDark = bgColor;  
  static const Color cardLight = Colors.white;
  static const Color cardPurple = primaryPurple;
  static const Color cardPurpleDark = primaryPurpleDark;
  static const Color bgCardDark = Colors.white;
  static const Color brandPurple = primaryPurple; 
  static const Color brandPurpleLight = primaryPurpleLight;
  static const Color emergencyRedBg = Color(0xFFFFF0F2);
  static const Color successGreenBg = successGreenLight;
  static const Color warningAmber = Color(0xFFF59E0B);
  static const Color infoBlue = Color(0xFF38BDF8);
  static const Color textSecondary = textGrey;

  // Powerful Premium Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryPurple, primaryPurpleDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient emergencyGradient = LinearGradient(
    colors: [emergencyRed, emergencyRedDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Premium Shadows
  static List<BoxShadow> softShadow = [
    BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
  ];
  
  static List<BoxShadow> premiumCardShadow = [
    BoxShadow(color: primaryPurple.withOpacity(0.06), blurRadius: 40, offset: const Offset(0, 20)),
    BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
  ];

  static List<BoxShadow> glowPurple = [
    BoxShadow(color: primaryPurple.withOpacity(0.35), blurRadius: 20, spreadRadius: 2)
  ];
  
  static List<BoxShadow> glowRed = [
    BoxShadow(color: emergencyRed.withOpacity(0.35), blurRadius: 20, spreadRadius: 2)
  ];

  static List<BoxShadow> innerGlowPurple = [
    BoxShadow(color: primaryPurple.withOpacity(0.2), blurRadius: 20, spreadRadius: -5)
  ];
}
