import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dreem_world/core/theme/index.dart';
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
}
