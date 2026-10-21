import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dreem_world/core/theme/index.dart';
import 'package:dreem_world/features/minigames/games/match_three_game_screen.dart';
import 'package:dreem_world/features/minigames/games/memory_game_screen.dart';
import 'package:dreem_world/features/minigames/games/quiz_game_screen.dart';
import 'package:dreem_world/features/minigames/mini_games_screen.dart';
import 'package:dreem_world/features/wallet/wallet_controller.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  group('Кошелёк', () {
    test('начисляет и списывает монеты', () async {
      final WalletController controller = WalletController();
      await Future<void>.delayed(Duration.zero);

      expect(controller.state.balance, 0);

      await controller.reward(30);
      expect(controller.state.balance, 30);

      final bool spent = await controller.spend(20);
      expect(spent, isTrue);
      expect(controller.state.balance, 10);

      final bool tooMuch = await controller.spend(100);
      expect(tooMuch, isFalse);
      expect(controller.state.balance, 10);
    });

    test('ежедневный бонус начисляется один раз и растит серию', () async {
      final WalletController controller = WalletController();
      await Future<void>.delayed(Duration.zero);

      expect(controller.canClaimDaily, isTrue);
      final int reward = await controller.claimDaily();
      expect(reward, greaterThan(0));
      expect(controller.state.balance, reward);
      expect(controller.state.streak, 1);

      expect(controller.canClaimDaily, isFalse);
      final int again = await controller.claimDaily();
      expect(again, 0);
      expect(controller.state.balance, reward);
    });

    test('награда за игру ограничена дневным лимитом', () async {
      final WalletController controller = WalletController();
      await Future<void>.delayed(Duration.zero);

      expect(controller.gamesRemaining, WalletController.dailyGameLimit);

      final int first = await controller.rewardFromGame(40);
      expect(first, 40);
      expect(controller.state.balance, 40);
      expect(controller.gamesRemaining, WalletController.dailyGameLimit - 40);

      // Запрос больше остатка — начислится только остаток.
      final int second = await controller.rewardFromGame(999);
      expect(second, WalletController.dailyGameLimit - 40);
      expect(controller.state.balance, WalletController.dailyGameLimit);
      expect(controller.gamesRemaining, 0);

      // Лимит исчерпан — больше не начисляем.
      final int third = await controller.rewardFromGame(30);
      expect(third, 0);
      expect(controller.state.balance, WalletController.dailyGameLimit);
    });
  });

  testWidgets('Экран мини-игр показывает баланс и кнопку бонуса', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.of(AppThemeName.neonViolet),
          home: const MiniGamesScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Ваш баланс'), findsOneWidget);
    expect(find.textContaining('монет'), findsWidgets);
    expect(find.textContaining('Забрать бонус за вход'), findsOneWidget);
    expect(find.text('Колесо удачи'), findsOneWidget);
  });

  testWidgets('Экран мини-игр показывает три новые игры', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.of(AppThemeName.neonViolet),
          home: const MiniGamesScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Викторина'), findsOneWidget);
    expect(find.text('Три в ряд'), findsOneWidget);
    expect(find.text('Мемори'), findsOneWidget);
    expect(find.text('Играть'), findsWidgets);
  });

  testWidgets('Викторина показывает вопрос и варианты', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.of(AppThemeName.neonViolet),
          home: const QuizGameScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Викторина'), findsOneWidget);
    expect(find.textContaining('Вопрос 1 из'), findsOneWidget);
    expect(find.textContaining('с'), findsWidgets);

    // Останавливаем таймер, чтобы тест завершился без висящих таймеров.
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Мемори рисует сетку карточек', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.of(AppThemeName.neonViolet),
          home: const MemoryGameScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Мемори'), findsOneWidget);
    expect(find.textContaining('Ходы:'), findsOneWidget);
    expect(find.textContaining('Пар найдено:'), findsOneWidget);
  });

  testWidgets('Три в ряд рисует поле и счёт', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.of(AppThemeName.neonViolet),
          home: const MatchThreeGameScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Три в ряд'), findsOneWidget);
    expect(find.textContaining('Очки:'), findsOneWidget);
    expect(find.textContaining('Ходы:'), findsOneWidget);
  });
}
