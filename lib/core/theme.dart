import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDark');
    if (isDark != null) {
      state = isDark ? ThemeMode.dark : ThemeMode.light;
    }
  }

  Future<void> toggleTheme() async {
    final isDark = state == ThemeMode.dark;
    state = isDark ? ThemeMode.light : ThemeMode.dark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDark', !isDark);
  }
}

class AppTheme {
  static final TextTheme _textTheme = GoogleFonts.spaceGroteskTextTheme();
  static final String _fontFamily = GoogleFonts.spaceGrotesk().fontFamily!;
  static final String _monoFont = GoogleFonts.spaceMono().fontFamily!;
  static final String _displayFont = GoogleFonts.doto().fontFamily!;

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: _fontFamily,
    textTheme: _textTheme.copyWith(
      displayLarge: GoogleFonts.doto(
        fontSize: 72,
        fontWeight: FontWeight.bold,
        color: Colors.black,
        letterSpacing: -2,
      ),
      displayMedium: GoogleFonts.doto(
        fontSize: 48,
        fontWeight: FontWeight.bold,
        color: Colors.black,
        letterSpacing: -1,
      ),
      headlineMedium: GoogleFonts.spaceGrotesk(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.black,
        letterSpacing: -0.5,
      ),
      bodyLarge: GoogleFonts.spaceGrotesk(
        fontSize: 16,
        color: Colors.black,
      ),
      labelSmall: GoogleFonts.spaceMono(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: Colors.black54,
        letterSpacing: 1.5,
      ),
    ),
    colorScheme: const ColorScheme.light(
      primary: Colors.black,
      onPrimary: Colors.white,
      surface: Color(0xFFF5F5F5), // Warm off-white
      onSurface: Colors.black,
      error: Color(0xFFD71921), // Nothing Red
      onError: Colors.white,
      surfaceContainer: Colors.white,
    ),
    scaffoldBackgroundColor: const Color(0xFFF5F5F5),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFFF5F5F5),
      elevation: 0,
      centerTitle: false,
      scrolledUnderElevation: 0,
      titleTextStyle: GoogleFonts.spaceMono(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.black,
        letterSpacing: 2,
      ),
      iconTheme: const IconThemeData(color: Colors.black, size: 20),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
      ),
      margin: EdgeInsets.zero,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        textStyle: GoogleFonts.spaceMono(
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
          fontSize: 14,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: Colors.black, width: 1.5),
      ),
      labelStyle: GoogleFonts.spaceMono(
        color: Colors.black54,
        fontSize: 12,
        letterSpacing: 1,
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: _fontFamily,
    textTheme: _textTheme.apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
    ).copyWith(
      displayLarge: GoogleFonts.doto(
        fontSize: 72,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        letterSpacing: -2,
      ),
      displayMedium: GoogleFonts.doto(
        fontSize: 48,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        letterSpacing: -1,
      ),
      headlineMedium: GoogleFonts.spaceGrotesk(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        letterSpacing: -0.5,
      ),
      bodyLarge: GoogleFonts.spaceGrotesk(
        fontSize: 16,
        color: Colors.white,
      ),
      labelSmall: GoogleFonts.spaceMono(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: Colors.white54,
        letterSpacing: 1.5,
      ),
    ),
    colorScheme: const ColorScheme.dark(
      primary: Colors.white,
      onPrimary: Colors.black,
      surface: Color(0xFF0A0A0A), // OLED Black
      onSurface: Colors.white,
      error: Color(0xFFD71921), // Nothing Red
      onError: Colors.white,
      surfaceContainer: Color(0xFF141414),
    ),
    scaffoldBackgroundColor: const Color(0xFF0A0A0A),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF0A0A0A),
      elevation: 0,
      centerTitle: false,
      scrolledUnderElevation: 0,
      titleTextStyle: GoogleFonts.spaceMono(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        letterSpacing: 2,
      ),
      iconTheme: const IconThemeData(color: Colors.white, size: 20),
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF141414),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Color(0xFF2C2C2C), width: 1),
      ),
      margin: EdgeInsets.zero,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        textStyle: GoogleFonts.spaceMono(
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
          fontSize: 14,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF141414),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: Color(0xFF2C2C2C), width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: Color(0xFF2C2C2C), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: Colors.white, width: 1.5),
      ),
      labelStyle: GoogleFonts.spaceMono(
        color: Colors.white54,
        fontSize: 12,
        letterSpacing: 1,
      ),
    ),
  );
}
