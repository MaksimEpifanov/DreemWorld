import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_theme.dart';

/// Ключ хранения выбранной темы в shared_preferences.
const String kThemeModeNameKey = 'theme_mode_name';

/// Контроллер выбранной темы (Riverpod + shared_preferences).
class ThemeController extends Notifier<AppThemeName> {
  int _epoch = 0;

  @override
  AppThemeName build() {
    _restore();
    return AppThemeName.neonViolet;
  }

  Future<void> _restore() async {
    final int epoch = _epoch;
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      if (epoch != _epoch) return;
      final AppThemeName restored = AppThemeName.fromStorage(
        prefs.getString(kThemeModeNameKey),
      );
      if (restored != state) state = restored;
    } catch (_) {
      // Недоступное хранилище — остаёмся на теме по умолчанию.
    }
  }

  Future<void> setTheme(AppThemeName name) async {
    _epoch++;
    state = name;
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(kThemeModeNameKey, name.storageValue);
    } catch (_) {
      // Недоступное хранилище — тема выбрана только на время сессии.
    }
  }
}

/// Провайдер выбранной темы.
final NotifierProvider<ThemeController, AppThemeName> themeControllerProvider =
    NotifierProvider<ThemeController, AppThemeName>(ThemeController.new);
