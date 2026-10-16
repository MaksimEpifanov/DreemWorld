import '../models/app_user.dart';

/// Ошибка аутентификации с человекочитаемым сообщением для UI.
class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Абстракция сервиса аутентификации.
///
/// TODO(R2): заменить мок-реализацию на реальный бэкенд (Supabase Auth).
abstract interface class AuthService {
  /// Регистрирует нового пользователя и сразу открывает сессию.
  Future<AppUser> register({
    required String email,
    required String password,
    required String name,
  });

  /// Входит в существующий аккаунт и открывает сессию.
  Future<AppUser> login({
    required String email,
    required String password,
  });

  /// Завершает текущую сессию.
  Future<void> logout();

  /// Восстанавливает сохранённую сессию или возвращает `null`.
  Future<AppUser?> restoreSession();
}
