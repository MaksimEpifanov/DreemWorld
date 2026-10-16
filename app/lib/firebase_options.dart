import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

/// Шаблон конфигурации Firebase.
///
/// Этот файл ещё НЕ настроен под реальный проект Firebase: [isConfigured]
/// равен `false`, поэтому приложение продолжает работать в мок-режиме.
///
/// После `flutterfire configure` замените этот файл сгенерированным
/// (он перезапишет класс [DefaultFirebaseOptions] реальными ключами)
/// и поставьте [isConfigured] в `true`.
class DefaultFirebaseOptions {
  const DefaultFirebaseOptions._();

  /// Флаг готовности конфигурации.
  ///
  /// Пока `false` — [Firebase.initializeApp] не вызывается, а
  /// аутентификация работает на `MockAuthService`.
  static const bool isConfigured = false;

  /// Опции текущей платформы.
  ///
  /// В шаблоне бросает исключение: сгенерированный `flutterfire configure`
  /// файл переопределяет этот геттер реальными значениями.
  static FirebaseOptions get currentPlatform => throw UnsupportedError(
    'Firebase не настроен. Выполните `flutterfire configure` и замените '
    'lib/firebase_options.dart сгенерированным файлом, затем поставьте '
    'DefaultFirebaseOptions.isConfigured = true.',
  );
}
