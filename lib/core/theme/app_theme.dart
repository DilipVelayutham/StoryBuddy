import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    final baseTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryPurple,
        primary: AppColors.primaryPurple,
        secondary: AppColors.skyBlue,
        tertiary: AppColors.sunshineYellow,
        background: AppColors.primaryLight,
        error: AppColors.errorRed,
      ),
      scaffoldBackgroundColor: Colors.transparent,
    );

    return baseTheme.copyWith(
      textTheme: GoogleFonts.fredokaTextTheme(baseTheme.textTheme).copyWith(
        displayLarge: GoogleFonts.fredoka(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.textDark,
        ),
        headlineMedium: GoogleFonts.fredoka(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.textDark,
          height: 1.2,
        ),
        titleLarge: GoogleFonts.fredoka(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
        bodyLarge: GoogleFonts.fredoka(
          fontSize: 18,
          fontWeight: FontWeight.normal,
          color: AppColors.textDark,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.fredoka(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: AppColors.textDark,
        ),
        labelLarge: GoogleFonts.fredoka(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.textLight,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.glassCardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.glassCardBorder, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryPurple,
          foregroundColor: AppColors.textLight,
          minimumSize: const Size(180, 54),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 4,
          shadowColor: AppColors.primaryPurple.withOpacity(0.3),
        ),
      ),
    );
  }
}
