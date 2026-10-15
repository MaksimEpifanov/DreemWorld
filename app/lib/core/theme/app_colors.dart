import 'package:flutter/material.dart';

/// Неоновые токены цветов Dreem World.
class AppColors {
  const AppColors._();

  static const Color background = Color(0xFF07060D);
  static const Color surface = Color(0xFF120F1F);
  static const Color surfaceElevated = Color(0xFF1B1730);

  static const Color textPrimary = Color(0xFFF4F1FF);
  static const Color textSecondary = Color(0xFFA79FC7);
  static const Color textMuted = Color(0xFF6F6790);

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF080510);

  static const Color success = Color(0xFF39FF88);
  static const Color warning = Color(0xFFFFC542);
  static const Color error = Color(0xFFFF4D6D);
  static const Color info = Color(0xFF00E5FF);

  static const Color transparent = Colors.transparent;
}

/// Палитра одной неоновой темы.
class NeonPalette {
  const NeonPalette({
    required this.id,
    required this.title,
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.background,
    required this.surface,
    required this.glow,
  });

  /// Строковый идентификатор (используется в shared_preferences).
  final String id;

  /// Человекочитаемое название.
  final String title;

  final Color primary;
  final Color secondary;
  final Color accent;
  final Color background;
  final Color surface;
  final Color glow;

  Color get onPrimary =>
      primary.computeLuminance() > 0.5 ? AppColors.black : AppColors.white;
}

/// Коллекция палитр Dreem World.
class AppPalettes {
  const AppPalettes._();

  static const NeonPalette neonViolet = NeonPalette(
    id: 'neon_violet',
    title: 'Neon Violet',
    primary: Color(0xFF7C4DFF),
    secondary: Color(0xFFB388FF),
    accent: Color(0xFFD500F9),
    background: Color(0xFF07060D),
    surface: Color(0xFF120F1F),
    glow: Color(0xFF7C4DFF),
  );

  static const NeonPalette cyberPink = NeonPalette(
    id: 'cyber_pink',
    title: 'Cyber Pink',
    primary: Color(0xFFFF2E88),
    secondary: Color(0xFFFF6EC7),
    accent: Color(0xFF7C4DFF),
    background: Color(0xFF0C0510),
    surface: Color(0xFF1A0E1C),
    glow: Color(0xFFFF2E88),
  );

  static const NeonPalette matrixGreen = NeonPalette(
    id: 'matrix_green',
    title: 'Matrix Green',
    primary: Color(0xFF39FF14),
    secondary: Color(0xFF00E676),
    accent: Color(0xFF00FFC3),
    background: Color(0xFF020A05),
    surface: Color(0xFF0A170D),
    glow: Color(0xFF39FF14),
  );

  static const NeonPalette neonSunset = NeonPalette(
    id: 'neon_sunset',
    title: 'Neon Sunset',
    primary: Color(0xFFFF6B35),
    secondary: Color(0xFFFFD166),
    accent: Color(0xFFFF2E88),
    background: Color(0xFF0D0508),
    surface: Color(0xFF1C0F12),
    glow: Color(0xFFFF6B35),
  );

  static const NeonPalette iceBlue = NeonPalette(
    id: 'ice_blue',
    title: 'Ice Blue',
    primary: Color(0xFF00D4FF),
    secondary: Color(0xFF7DF9FF),
    accent: Color(0xFF4D7CFF),
    background: Color(0xFF03080F),
    surface: Color(0xFF0B1522),
    glow: Color(0xFF00D4FF),
  );

  static const List<NeonPalette> all = <NeonPalette>[
    neonViolet,
    cyberPink,
    matrixGreen,
    neonSunset,
    iceBlue,
  ];
}
