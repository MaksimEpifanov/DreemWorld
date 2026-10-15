import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/chat/chat_screen.dart';
import '../../features/chat/conversations_list_screen.dart';
import '../../features/discovery/discovery_screen.dart';
import '../../features/match/match_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/onboarding/splash_screen.dart';
import '../../features/profile/profile_setup_screen.dart';
import '../../features/profile/profile_view_edit_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
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
        return const Scaffold(
          body: Center(child: Text('Settings')),
        );
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
