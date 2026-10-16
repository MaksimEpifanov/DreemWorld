import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_user.dart';
import 'auth_service.dart';

/// Реализация [AuthService] поверх Firebase Authentication.
///
/// Используется только тогда, когда Firebase реально инициализирован
/// (см. [isFirebaseInitialized]). При отсутствии конфигурации приложение
/// работает на `MockAuthService`.
class FirebaseAuthService implements AuthService {
  FirebaseAuth get _auth => FirebaseAuth.instance;

  AppUser _toAppUser(User user) => AppUser(
    id: user.uid,
    email: user.email ?? '',
    name: user.displayName ?? user.email ?? '',
  );

  @override
  Future<AppUser> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final UserCredential credential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      final User? user = credential.user;
      if (user == null) {
        throw const AuthException('Не удалось создать аккаунт');
      }
      await user.updateDisplayName(name);
      return AppUser(id: user.uid, email: user.email ?? email, name: name);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_registerMessage(e));
    } catch (_) {
      throw const AuthException('Не удалось создать аккаунт');
    }
  }

  @override
  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final User? user = credential.user;
      if (user == null) {
        throw const AuthException('Неверный email или пароль');
      }
      return _toAppUser(user);
    } on FirebaseAuthException {
      throw const AuthException('Неверный email или пароль');
    } catch (_) {
      throw const AuthException('Неверный email или пароль');
    }
  }

  @override
  Future<void> logout() async {
    await _auth.signOut();
  }

  @override
  Future<AppUser?> restoreSession() async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) return null;
      return _toAppUser(user);
    } catch (_) {
      return null;
    }
  }

  String _registerMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Пользователь с таким email уже существует';
      case 'invalid-email':
        return 'Некорректный email';
      case 'weak-password':
        return 'Слишком слабый пароль';
      case 'operation-not-allowed':
        return 'Вход по email/паролю отключён в настройках Firebase';
      case 'network-request-failed':
        return 'Нет подключения к интернету';
      default:
        return 'Не удалось создать аккаунт';
    }
  }
}
