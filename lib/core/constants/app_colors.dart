import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Brand Colors (Joyful Violet / Lavender focus)
  static const Color primaryPurple = Color(0xFF8B5CF6);      // Soft vibrant purple
  static const Color primaryDeepPurple = Color(0xFF6D28D9);  // Rich violet
  static const Color primaryLight = Color(0xFFF5F3FF);       // Pastel lavender white
  static const Color lavender = Color(0xFFE0E7FF);           // Soft lavender grey/blue

  // Glassmorphism Base Colors
  static const Color glassCardBg = Color(0x3DFFFFFF);        // Highly transparent white
  static const Color glassCardBorder = Color(0x80FFFFFF);    // Semi-transparent border
  static const Color glassVioletBg = Color(0x268B5CF6);      // Translucent purple tint
  static const Color glassVioletBorder = Color(0x4D8B5CF6);  // Translucent purple border

  // Supporting Accent Colors (Vibrant, high-contrast, playful)
  static const Color sunshineYellow = Color(0xFFFFD54F);     // Warm happy yellow
  static const Color skyBlue = Color(0xFF4FC3F7);            // Playful sky blue
  static const Color mintGreen = Color(0xFF4DB6AC);          // Calming mint green
  static const Color coralOrange = Color(0xFFFF8A65);        // Enthusiastic coral orange
  static const Color candyPink = Color(0xFFF06292);          // Friendly candy pink

  // UI Utilities
  static const Color textDark = Color(0xFF1E1B4B);           // Deep indigo for text (no harsh black)
  static const Color textLight = Color(0xFFFFFFFF);          // Clear white text
  static const Color textMuted = Color(0xFF4B5563);          // Grey for subtitle text
  static const Color successGreen = Color(0xFF81C784);       // Success indicators
  static const Color errorRed = Color(0xFFE57373);           // Warning/Error markers
  
  // Magical Background Gradient
  static const List<Color> backgroundGradient = [
    Color(0xFFF5F3FF), // Soft lilac white
    Color(0xFFE0E7FF), // Dreamy lavender
    Color(0xFFEEF2FF), // Warm indigo-tinted white
  ];
}
