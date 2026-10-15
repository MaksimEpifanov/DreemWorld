import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dreem_world/core/theme/index.dart';

void main() {
  group('AppPalettes', () {
    test('contains 5 unique themes with unique ids', () {
      expect(AppPalettes.all, hasLength(5));
      expect(
        AppPalettes.all.map((NeonPalette p) => p.id).toSet(),
        hasLength(5),
      );
      expect(
        AppPalettes.all.map((NeonPalette p) => p.title).toSet(),
        hasLength(5),
      );
      expect(AppThemeName.values, hasLength(5));
    });
  });

  group('AppTheme', () {
    test('builds Material 3 dark ThemeData for every theme', () {
      for (final AppThemeName name in AppThemeName.values) {
        final ThemeData theme = AppTheme.of(name);
        expect(theme.useMaterial3, isTrue);
        expect(theme.brightness, Brightness.dark);
        expect(theme.colorScheme.primary, name.palette.primary);
        expect(theme.scaffoldBackgroundColor, name.palette.background);
      }
    });
  });

  group('ThemeController', () {
    test('defaults to Neon Violet and persists selected theme', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final ProviderContainer container = ProviderContainer();

      expect(container.read(themeControllerProvider), AppThemeName.neonViolet);

      await container
          .read(themeControllerProvider.notifier)
          .setTheme(AppThemeName.iceBlue);

      expect(container.read(themeControllerProvider), AppThemeName.iceBlue);

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(kThemeModeNameKey), 'ice_blue');
      expect(AppThemeName.fromStorage(prefs.getString(kThemeModeNameKey)),
          AppThemeName.iceBlue);
      expect(AppThemeName.fromStorage('unknown'), AppThemeName.neonViolet);
      expect(AppThemeName.fromStorage(null), AppThemeName.neonViolet);

      container.dispose();
    });

    test('restores theme from stored value on startup', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        kThemeModeNameKey: 'neon_sunset',
      });
      final ProviderContainer container = ProviderContainer();

      container.listen<AppThemeName>(
        themeControllerProvider,
        (_, __) {},
        fireImmediately: true,
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(container.read(themeControllerProvider), AppThemeName.neonSunset);
      container.dispose();
    });
  });
}
