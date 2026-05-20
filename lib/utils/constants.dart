import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Dark Mode colors
  static const Color darkBlack = Color(0xFF000000);
  static const Color darkSurface = Color(0xFF111111);
  static const Color darkSurfaceRaised = Color(0xFF1A1A1A);
  static const Color darkBorder = Color(0xFF222222);
  static const Color darkBorderVisible = Color(0xFF333333);
  static const Color darkTextDisabled = Color(0xFF666666);
  static const Color darkTextSecondary = Color(0xFF999999);
  static const Color darkTextPrimary = Color(0xFFE8E8E8);
  static const Color darkTextDisplay = Color(0xFFFFFFFF);

  // Light Mode colors
  static const Color lightBlack = Color(0xFFF5F5F5);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceRaised = Color(0xFFF0F0F0);
  static const Color lightBorder = Color(0xFFE8E8E8);
  static const Color lightBorderVisible = Color(0xFFCCCCCC);
  static const Color lightTextDisabled = Color(0xFF999999);
  static const Color lightTextSecondary = Color(0xFF666666);
  static const Color lightTextPrimary = Color(0xFF1A1A1A);
  static const Color lightTextDisplay = Color(0xFF000000);

  // Status colors (Shared across modes)
  static const Color accent = Color(0xFFD71921); // Signal light / Error red
  static const Color success = Color(0xFF4A9E5C); // Green
  static const Color warning = Color(0xFFD4A843); // Amber
  static const Color interactiveDark = Color(0xFF5B9BF6);
  static const Color interactiveLight = Color(0xFF007AFF);
}

class AppSpacing {
  static const double xs2 = 2.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xl2 = 48.0;
  static const double xl3 = 64.0;
  static const double xl4 = 96.0;
}

class AppTheme {
  static ThemeData getDarkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBlack,
      cardColor: AppColors.darkSurface,
      dividerColor: AppColors.darkBorder,
      primaryColor: AppColors.accent,
      textTheme: TextTheme(
        displayLarge: GoogleFonts.doto(
          color: AppColors.darkTextDisplay,
          fontSize: 72,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.03,
        ),
        displayMedium: GoogleFonts.doto(
          color: AppColors.darkTextDisplay,
          fontSize: 48,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.02,
        ),
        displaySmall: GoogleFonts.doto(
          color: AppColors.darkTextDisplay,
          fontSize: 36,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.02,
        ),
        headlineMedium: GoogleFonts.spaceGrotesk(
          color: AppColors.darkTextDisplay,
          fontSize: 24,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.01,
        ),
        titleMedium: GoogleFonts.spaceGrotesk(
          color: AppColors.darkTextPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w400,
        ),
        bodyLarge: GoogleFonts.spaceGrotesk(
          color: AppColors.darkTextPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        bodySmall: GoogleFonts.spaceGrotesk(
          color: AppColors.darkTextSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        labelMedium: GoogleFonts.spaceMono(
          color: AppColors.darkTextSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.08,
        ),
      ),
    );
  }

  static ThemeData getLightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBlack,
      cardColor: AppColors.lightSurface,
      dividerColor: AppColors.lightBorder,
      primaryColor: AppColors.accent,
      textTheme: TextTheme(
        displayLarge: GoogleFonts.doto(
          color: AppColors.lightTextDisplay,
          fontSize: 72,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.03,
        ),
        displayMedium: GoogleFonts.doto(
          color: AppColors.lightTextDisplay,
          fontSize: 48,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.02,
        ),
        displaySmall: GoogleFonts.doto(
          color: AppColors.lightTextDisplay,
          fontSize: 36,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.02,
        ),
        headlineMedium: GoogleFonts.spaceGrotesk(
          color: AppColors.lightTextDisplay,
          fontSize: 24,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.01,
        ),
        titleMedium: GoogleFonts.spaceGrotesk(
          color: AppColors.lightTextPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w400,
        ),
        bodyLarge: GoogleFonts.spaceGrotesk(
          color: AppColors.lightTextPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        bodySmall: GoogleFonts.spaceGrotesk(
          color: AppColors.lightTextSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        labelMedium: GoogleFonts.spaceMono(
          color: AppColors.lightTextSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.08,
        ),
      ),
    );
  }
}
