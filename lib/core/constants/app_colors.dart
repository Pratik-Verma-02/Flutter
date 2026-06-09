import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Palette
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF9D97FF);
  static const Color primaryDark = Color(0xFF4A42E8);

  // Secondary Palette
  static const Color secondary = Color(0xFF00D4FF);
  static const Color secondaryLight = Color(0xFF5CE5FF);
  static const Color secondaryDark = Color(0xFF00A3CC);

  // Accent Palette
  static const Color accent = Color(0xFFFF6B6B);
  static const Color accentLight = Color(0xFFFF9B9B);
  static const Color accentDark = Color(0xFFE84545);

  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  // Dark Theme Surfaces
  static const Color darkBackground = Color(0xFF0A0A1A);
  static const Color darkSurface = Color(0xFF12122A);
  static const Color darkCard = Color(0xFF1A1A3E);
  static const Color darkCardElevated = Color(0xFF222254);
  static const Color darkBorder = Color(0xFF2A2A5A);

  // Light Theme Surfaces
  static const Color lightBackground = Color(0xFFF8F9FE);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFF0F1FA);
  static const Color lightCardElevated = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE4E5F1);

  // Text Colors
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFB0B0D0);
  static const Color darkTextTertiary = Color(0xFF7070A0);
  static const Color lightTextPrimary = Color(0xFF1A1A2E);
  static const Color lightTextSecondary = Color(0xFF5A5A7A);
  static const Color lightTextTertiary = Color(0xFF9A9AB0);

  // Status Colors
  static const Color success = Color(0xFF28C840);
  static const Color warning = Color(0xFFFFBD2E);
  static const Color error = Color(0xFFFF5F57);
  static const Color info = Color(0xFF00D4FF);

  // Terminal Colors
  static const Color terminalBg = Color(0xFF1E1E1E);
  static const Color terminalText = Color(0xFFE0E0E0);
  static const Color terminalGreen = Color(0xFF50FA7B);
  static const Color terminalYellow = Color(0xFFF1FA8C);
  static const Color terminalCyan = Color(0xFF8BE9FD);
  static const Color terminalRed = Color(0xFFFF5555);
  static const Color terminalDotRed = Color(0xFFFF5F57);
  static const Color terminalDotYellow = Color(0xFFFFBD2E);
  static const Color terminalDotGreen = Color(0xFF28C840);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, secondary],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6C63FF), Color(0xFF00D4FF), Color(0xFF4ECDC4)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, Color(0xFFFF8E53)],
  );

  static const LinearGradient darkSurfaceGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [darkCard, darkCardElevated],
  );

  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0A0A2E), Color(0xFF1A1A4E), Color(0xFF6C63FF)],
  );
}
