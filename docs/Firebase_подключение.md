# Подключение Firebase Authentication к Dreem World

Приложение написано так, что Firebase — **опциональный** слой. Пока он не
настроен, аутентификация работает в мок-режиме (`MockAuthService`), поэтому
веб-демо и APK работают без реального бэкенда. Ниже — как включить Firebase.

## 1. Создайте проект Firebase

1. Откройте [Firebase Console](https://console.firebase.google.com/).
2. Нажмите **Add project** и создайте проект (например, `dreem-world`).
3. Google Analytics можно отключить — для аутентификации он не обязателен.

## 2. Установите Firebase CLI и FlutterFire CLI

```powershell
npm install -g firebase-tools
dart pub global activate flutterfire_cli
```

Проверьте, что `%LOCALAPPDATA%\Pub\Cache\bin` добавлен в `PATH`, и войдите:

```powershell
firebase login
```

## 3. Сгенерируйте конфигурацию

Из каталога `app/` выполните:

```powershell
flutterfire configure
```

- выберите созданный проект Firebase;
- отметьте платформы (web, android, ios — по необходимости).

Команда:
- создаст/перезапишет `app/lib/firebase_options.dart` реальными ключами;
- добавит `android/app/google-services.json`;
- добавит `ios/Runner/GoogleService-Info.plist`.

## 4. Включите вход по Email/Password

Firebase Console → **Build → Authentication → Sign-in method** →
включите провайдер **Email/Password** и сохраните.

## 5. Включите флаг готовности

В сгенерированном `app/lib/firebase_options.dart` убедитесь, что
`isConfigured`:

```dart
static const bool isConfigured = true;
```

Теперь `initFirebaseIfConfigured()` при старте вызовет
`Firebase.initializeApp(...)`, и `authServiceProvider` начнёт отдавать
`FirebaseAuthService` вместо `MockAuthService`.

## 6. Настройки Android (SHA-1)

Для входа по email/паролю SHA-1 не обязателен, но нужен для Google-входа:

```powershell
cd android
.\gradlew signingReport
```

Скопируйте отпечаток **SHA1** и добавьте его в Console → **Project settings
→ Your apps → Android → Add fingerprint**, затем повторно скачайте
`google-services.json`.

## 7. Проверка

```powershell
$env:Path += ";C:\flutter\bin"
cd app
flutter pub get
flutter analyze
flutter test
flutter run
```

**Ожидаемый результат:** регистрация и вход создают реального пользователя
в Firebase Console → Authentication → Users. Чтобы вернуться в мок-режим,
достаточно поставить `isConfigured = false` (или удалить
`firebase_options.dart` и восстановить шаблон).

## Откат на мок-режим

Мок-режим включается автоматически, если:

- `DefaultFirebaseOptions.isConfigured == false`, **или**
- `Firebase.initializeApp` завершился ошибкой (например, битые ключи).

В обоих случаях `isFirebaseInitialized` остаётся `false`, и приложение
работает на `MockAuthService` без падений.
