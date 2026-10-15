import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dreem_world/core/theme/index.dart';
import 'package:dreem_world/data/models/profile.dart';
import 'package:dreem_world/data/repositories/mock_profile_repository.dart';
import 'package:dreem_world/features/discovery/widgets/user_card.dart';
import 'package:dreem_world/features/match/match_screen.dart';

void main() {
  final Profile anna = MockProfileRepository.seedProfiles[1];

  group('UserCard', () {
    testWidgets('показывает профиль, совместимость и реагирует на кнопки', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1000, 2200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      bool liked = false;
      bool passed = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.of(AppThemeName.neonViolet),
          home: Scaffold(
            body: SingleChildScrollView(
              child: UserCard(
                profile: anna,
                compatibility: 87,
                onLike: () => liked = true,
                onPass: () => passed = true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Анна'), findsOneWidget);
      expect(find.text('${anna.age}'), findsOneWidget);
      expect(find.text(anna.city!), findsOneWidget);
      expect(find.text('87%'), findsOneWidget);
      expect(find.text('Нравится'), findsOneWidget);
      expect(find.text('Пропустить'), findsOneWidget);

      await tester.tap(find.text('Нравится'));
      await tester.tap(find.text('Пропустить'));
      expect(liked, isTrue);
      expect(passed, isTrue);
    });
  });

  group('MatchScreen', () {
    testWidgets('показывает взаимную симпатию и обе кнопки', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1000, 2200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.of(AppThemeName.neonViolet),
            home: const MatchScreen(userId: 'p_anna'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('У вас взаимная симпатия!'), findsOneWidget);
      expect(find.textContaining('Анна'), findsWidgets);
      expect(find.text('Написать'), findsOneWidget);
      expect(find.text('Продолжить поиск'), findsOneWidget);
    });

    testWidgets('без пользователя показывает заглушку', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.of(AppThemeName.neonViolet),
            home: const MatchScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Мэтч не найден'), findsOneWidget);
    });
  });
}
