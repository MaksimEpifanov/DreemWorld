import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/app_user.dart';
import 'auth_service.dart';

class FirebaseAuthService implements AuthService {
  FirebaseAuthService({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  })  : _auth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  static const String _usersCollection = 'users';

  AppUser _userFromFirebase(User user, {String? fallbackName}) {
    final String displayName =
        user.displayName?.trim().isNotEmpty == true
            ? user.displayName!.trim()
            : (fallbackName ?? user.email?.split('@').first ?? 'User');

    return AppUser(
      id: user.uid,
      email: user.email ?? '',
      name: displayName,
    );
  }

  Future<void> _ensureUserDocument(User user, {String? fallbackName}) async {
    final String finalName =
        user.displayName?.trim().isNotEmpty == true
            ? user.displayName!.trim()
            : (fallbackName ?? user.email?.split('@').first ?? 'User');

    final DocumentReference<Map<String, dynamic>> ref =
        _firestore.collection(_usersCollection).doc(user.uid);

    final DocumentSnapshot<Map<String, dynamic>> snapshot = await ref.get();
    final Map<String, dynamic> payload = <String, dynamic>{
      'id': user.uid,
      'email': user.email ?? '',
      'name': finalName,
      'emailVerified': user.emailVerified,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (!snapshot.exists) {
      payload['createdAt'] = FieldValue.serverTimestamp();
      await ref.set(payload);
      return;
    }

    await ref.update(payload);
  }

  String _mapError(FirebaseAuthException error) {
    switch (error.code) {
      case 'email-already-in-use':
        return 'Пользователь с таким email уже существует';
      case 'invalid-email':
        return 'Некорректный email';
      case 'weak-password':
        return 'Пароль слишком слабый';
      case 'wrong-password':
        return 'Неверный email или пароль';
      case 'user-not-found':
        return 'Пользователь не найден';
      case 'user-disabled':
        return 'Аккаунт отключён';
      case 'too-many-requests':
        return 'Слишком много попыток. Попробуйте позже';
      case 'network-request-failed':
        return 'Проблемы с интернет-соединением';
      case 'account-exists-with-different-credential':
        return 'Уже существует аккаунт с другим методом входа';
      case 'invalid-credential':
        return 'Некорректные данные для входа';
      default:
        return error.message ?? 'Ошибка регистрации или входа';
    }
  }

  @override
  Future<AppUser> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final User? user = credential.user;
      if (user == null) {
        throw const AuthException('Не удалось создать аккаунт');
      }

      final String safeName = name.trim();
      await user.updateDisplayName(safeName);
      await user.reload();
      final User refreshedUser = _auth.currentUser!;
      await _ensureUserDocument(refreshedUser, fallbackName: safeName);
      await refreshedUser.sendEmailVerification();

      await _auth.signOut();
      return _userFromFirebase(refreshedUser, fallbackName: safeName);
    } on FirebaseAuthException catch (error) {
      throw AuthException(_mapError(error));
    } on AuthException {
      rethrow;
    } catch (_) {
      throw const AuthException('Не удалось создать аккаунт. Попробуйте ещё раз.');
    }
  }

  @override
  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final User? user = credential.user;
      if (user == null) {
        throw const AuthException('Не удалось войти в аккаунт');
      }

      if (!user.emailVerified) {
        await _auth.signOut();
        throw const AuthException(
          'Подтвердите email до входа. Проверьте почту и повторите попытку.',
        );
      }

      await _ensureUserDocument(user, fallbackName: user.email?.split('@').first);
      return _userFromFirebase(user);
    } on FirebaseAuthException catch (error) {
      throw AuthException(_mapError(error));
    } on AuthException {
      rethrow;
    } catch (_) {
      throw const AuthException('Не удалось войти. Попробуйте ещё раз.');
    }
  }

  @override
  Future<void> logout() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  @override
  Future<AppUser?> restoreSession() async {
    final User? user = _auth.currentUser;
    if (user == null) {
      return null;
    }

    if (!user.emailVerified) {
      return null;
    }

    await _ensureUserDocument(user, fallbackName: user.email?.split('@').first);
    return _userFromFirebase(user);
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (error) {
      throw AuthException(_mapError(error));
    } catch (_) {
      throw const AuthException('Не удалось отправить письмо для сброса пароля');
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    final User? user = _auth.currentUser;
    if (user == null) {
      throw const AuthException('Сессия не активна');
    }

    try {
      await user.sendEmailVerification();
    } on FirebaseAuthException catch (error) {
      throw AuthException(_mapError(error));
    } catch (_) {
      throw const AuthException('Не удалось отправить письмо для подтверждения email');
    }
  }

  @override
  Future<AppUser> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account == null) {
        throw const AuthException('Вход через Google был отменён');
      }

      final GoogleSignInAuthentication auth = await account.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: auth.accessToken,
        idToken: auth.idToken,
      );

      final UserCredential result = await _auth.signInWithCredential(credential);
      final User? user = result.user;
      if (user == null) {
        throw const AuthException('Не удалось войти через Google');
      }

      await _ensureUserDocument(user, fallbackName: user.email?.split('@').first);
      return _userFromFirebase(user);
    } on FirebaseAuthException catch (error) {
      throw AuthException(_mapError(error));
    } on AuthException {
      rethrow;
    } catch (_) {
      throw const AuthException('Не удалось войти через Google');
    }
  }
}

path: "app/lib/data/services/index.dart"
content: "export 'ai_service.dart';\nexport 'auth_service.dart';\nexport 'firebase_auth_service.dart';\nexport 'mock_ai_service.dart';\nexport 'mock_auth_service.dart';\nexport 'mock_realtime_service.dart';\nexport 'mock_translation_service.dart';\nexport 'realtime_service.dart';\nexport 'supabase_realtime_service.dart';\nexport 'translation_service.dart';\n"
},{