import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/providers/auth_providers.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/chat/chat_screen.dart';
import '../../features/chat/conversations_list_screen.dart';
import '../../features/discovery/discovery_screen.dart';
import '../../features/match/match_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/onboarding/splash_screen.dart';
import '../../features/profile/profile_setup_screen.dart';
import '../../features/profile/profile_view_edit_screen.dart';
import '../../features/settings/settings_screen.dart';

/// Публичные маршруты, доступные без аутентификации.
const Set<String> _publicRoutes = <String>{
  '/login',
  '/register',
  '/onboarding',
  '/splash',
};

/// Слушатель состояния аутентификации для `GoRouter.refreshListenable`.
///
/// При смене состояния вызывает [notifyListeners], из-за чего `GoRouter`
/// пересчитывает `redirect` без пересоздания (стек сохраняется).
class RouterNotifier extends ChangeNotifier {
  RouterNotifier(Ref ref) {
    _subscription = ref.listen<AuthState>(
      authControllerProvider,
      (AuthState? previous, AuthState next) => notifyListeners(),
    );
  }

  ProviderSubscription<AuthState>? _subscription;

  @override
  void dispose() {
    _subscription?.close();
    _subscription = null;
    super.dispose();
  }
}

/// Провайдер роутера приложения.
///
/// Создаётся один раз и живёт вместе с приложением; реагирует на изменение
/// статуса аутентификации через [RouterNotifier].
final Provider<GoRouter> routerProvider = Provider<GoRouter>((Ref ref) {
  final RouterNotifier notifier = RouterNotifier(ref);
  ref.onDispose(notifier.dispose);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: notifier,
    redirect: (BuildContext context, GoRouterState state) {
      final AuthState auth = ref.read(authControllerProvider);
      final String location = state.matchedLocation;
      final bool isLogin = location == '/login' || location == '/register';

      // Восстановление сессии: держимся на сплэше.
      if (auth.isUnknown) {
        return location == '/splash' ? null : '/splash';
      }

      // Не авторизован.
      if (!auth.isAuthenticated) {
        if (location == '/splash') return '/onboarding';
        if (_publicRoutes.contains(location)) return null;
        return '/login';
      }

      // Авторизован: со сплэша — на главную, со вход/регистрации — к анкете.
      if (location == '/splash') return '/main';
      if (isLogin) return '/profile-setup';
      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (BuildContext context, GoRouterState state) {
          return const SplashScreen();
        },
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (BuildContext context, GoRouterState state) {
          return const OnboardingScreen();
        },
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (BuildContext context, GoRouterState state) {
          return const LoginScreen();
        },
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (BuildContext context, GoRouterState state) {
          return const RegisterScreen();
        },
      ),
      GoRoute(
        path: '/profile-setup',
        name: 'profile-setup',
        builder: (BuildContext context, GoRouterState state) {
          return const ProfileSetupScreen();
        },
      ),
      GoRoute(
        path: '/main',
        name: 'main',
        builder: (BuildContext context, GoRouterState state) {
          return const DiscoveryScreen();
        },
      ),
      GoRoute(
        path: '/chats',
        name: 'chats',
        builder: (BuildContext context, GoRouterState state) {
          return const ConversationsListScreen();
        },
      ),
      GoRoute(
        path: '/chat/:id',
        name: 'chat',
        builder: (BuildContext context, GoRouterState state) {
          final String id = state.pathParameters['id'] ?? '';
          return ChatScreen(conversationId: id);
        },
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (BuildContext context, GoRouterState state) {
          return const SettingsScreen();
        },
      ),
      GoRoute(
        path: '/match',
        name: 'match',
        builder: (BuildContext context, GoRouterState state) {
          final String? userId = state.uri.queryParameters['userId'];
          return MatchScreen(userId: userId);
        },
      ),
      GoRoute(
        path: '/profile-edit',
        name: 'profile-edit',
        builder: (BuildContext context, GoRouterState state) {
          return const ProfileViewEditScreen();
        },
      ),
    ],
  );
});
