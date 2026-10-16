import 'package:firebase_core/firebase_core.dart';

import '../../firebase_options.dart';

bool _initialized = false;

/// Признак того, что Firebase успешно инициализирован.
///
/// Пока `false`, приложение работает в мок-режиме (веб-демо и APK
/// остаются работоспособными без реальной конфигурации Firebase).
bool get isFirebaseInitialized => _initialized;

/// Инициализирует Firebase, если он настроен.
///
/// Если [DefaultFirebaseOptions.isConfigured] равен `false`, ничего не делает.
/// Любая ошибка инициализации проглатывается — флаг остаётся `false`, и
/// приложение безопасно откатывается на мок-реализации.
Future<void> initFirebaseIfConfigured() async {
  if (!DefaultFirebaseOptions.isConfigured) {
    return;
  }
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    _initialized = true;
  } catch (_) {
    _initialized = false;
  }
}
