import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_spacing.dart';
import 'app_text_styles.dart';

/// Названия неоновых тем Dreem World.
enum AppThemeName {
  neonViolet(AppPalettes.neonViolet),
  cyberPink(AppPalettes.cyberPink),
  matrixGreen(AppPalettes.matrixGreen),
  neonSunset(AppPalettes.neonSunset),
  iceBlue(AppPalettes.iceBlue);

  const AppThemeName(this.palette);

  final NeonPalette palette;

  /// Значение, хранимое в shared_preferences (ключ `theme_mode_name`).
  String get storageValue => palette.id;

  static AppThemeName fromStorage(String? value) {
    for (final theme in values) {
      if (theme.storageValue == value) return theme;
    }
    return AppThemeName.neonViolet;
  }
}

/// Построение Material 3 тем из неоновых палитр.
class AppTheme {
  const AppTheme._();

  static ThemeData of(AppThemeName name) {
    final NeonPalette palette = name.palette;
    final ColorScheme scheme = _colorScheme(palette);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: Colors.transparent,
      extensions: <ThemeExtension<dynamic>>[
        NeonPaletteExtension(palette: palette),
      ],
      textTheme: _textTheme(scheme),
      appBarTheme: AppBarThemeData(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.headline(),
      ),
      cardTheme: CardThemeData(
        color: palette.surface.withValues(alpha: 0.75),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.lgAll,
          side: BorderSide(color: palette.primary.withValues(alpha: 0.5)),
        ),
        margin: EdgeInsets.zero,
      ),
      filledButtonTheme: FilledButtonThemeData(style: _buttonStyle(scheme)),
      elevatedButtonTheme: ElevatedButtonThemeData(style: _buttonStyle(scheme)),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: _buttonStyle(scheme).copyWith(
          side: WidgetStatePropertyAll<BorderSide>(
            BorderSide(color: palette.primary.withValues(alpha: 0.8)),
          ),
          backgroundColor: const WidgetStatePropertyAll<Color>(
            Colors.transparent,
          ),
          foregroundColor: WidgetStatePropertyAll<Color>(palette.primary),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: _buttonStyle(scheme).copyWith(
          backgroundColor: const WidgetStatePropertyAll<Color>(
            Colors.transparent,
          ),
          foregroundColor: WidgetStatePropertyAll<Color>(palette.primary),
          elevation: const WidgetStatePropertyAll<double>(0),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.surface.withValues(alpha: 0.9),
        hintStyle: AppTextStyles.body(color: AppColors.textMuted),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + 4,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.mdAll,
          borderSide: BorderSide(color: palette.primary.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdAll,
          borderSide: BorderSide(color: palette.primary.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdAll,
          borderSide: BorderSide(color: palette.primary, width: 1.6),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: palette.primary.withValues(alpha: 0.2),
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: palette.surface,
        contentTextStyle: AppTextStyles.body(),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
      ),
    );
  }

  static ColorScheme _colorScheme(NeonPalette palette) {
    final Color primary = palette.primary;
    final Color onPrimary = palette.onPrimary;
    return ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.dark,
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: primary.withValues(alpha: 0.18),
      onPrimaryContainer: primary,
      secondary: palette.secondary,
      onSecondary: palette.onPrimary,
      secondaryContainer: palette.secondary.withValues(alpha: 0.16),
      onSecondaryContainer: palette.secondary,
      tertiary: palette.accent,
      onTertiary: AppColors.black,
      tertiaryContainer: palette.accent.withValues(alpha: 0.16),
      onTertiaryContainer: palette.accent,
      error: AppColors.error,
      onError: AppColors.white,
      errorContainer: AppColors.error.withValues(alpha: 0.16),
      onErrorContainer: AppColors.error,
      surface: palette.background,
      onSurface: AppColors.textPrimary,
      onSurfaceVariant: AppColors.textSecondary,
      outline: palette.secondary.withValues(alpha: 0.45),
      outlineVariant: palette.secondary.withValues(alpha: 0.18),
      shadow: palette.glow,
      scrim: Colors.black.withValues(alpha: 0.6),
    );
  }

  static TextTheme _textTheme(ColorScheme scheme) {
    return TextTheme(
      displayLarge: AppTextStyles.display(color: scheme.onSurface),
      headlineLarge: AppTextStyles.headline(color: scheme.onSurface),
      titleLarge: AppTextStyles.title(color: scheme.onSurface),
      bodyMedium: AppTextStyles.body(color: scheme.onSurface),
      labelMedium: AppTextStyles.label(color: scheme.onSurface),
      bodySmall: AppTextStyles.caption(color: scheme.onSurfaceVariant),
    );
  }

  static ButtonStyle _buttonStyle(ColorScheme scheme) {
    return FilledButton.styleFrom(
      backgroundColor: scheme.primary,
      foregroundColor: scheme.onPrimary,
      disabledBackgroundColor: scheme.primary.withValues(alpha: 0.25),
      disabledForegroundColor: scheme.onPrimary.withValues(alpha: 0.5),
      elevation: 0,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md - 2,
      ),
      minimumSize: const Size(64, 48),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
      textStyle: AppTextStyles.title(color: scheme.onPrimary),
    );
  }
}

class NeonPaletteExtension extends ThemeExtension<NeonPaletteExtension> {
  const NeonPaletteExtension({required this.palette});

  final NeonPalette palette;

  @override
  ThemeExtension<NeonPaletteExtension> copyWith({NeonPalette? palette}) {
    return NeonPaletteExtension(palette: palette ?? this.palette);
  }

  @override
  ThemeExtension<NeonPaletteExtension> lerp(
    covariant ThemeExtension<NeonPaletteExtension>? other,
    double t,
  ) {
    if (other is! NeonPaletteExtension) return this;
    return NeonPaletteExtension(palette: other.palette);
  }
}
