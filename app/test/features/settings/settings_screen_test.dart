import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dreem_world/core/config/app_info.dart';
import 'package:dreem_world/core/theme/index.dart';
import 'package:dreem_world/features/settings/settings_screen.dart';

void main() {
  testWidgets('SettingsScreen показывает темы, приватность и версию', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues(<String, Object>{});

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: SettingsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Настройки'), findsOneWidget);
    expect(find.text('Тема оформления'), findsOneWidget);
    expect(find.text('Приватность'), findsOneWidget);
    expect(find.text('О приложении'), findsOneWidget);
    expect(find.text(AppInfo.version), findsOneWidget);
    expect(find.text('Выйти'), findsOneWidget);
  });

  testWidgets('переключатель приватности меняет состояние', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues(<String, Object>{});

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.of(AppThemeName.neonViolet),
          home: const SettingsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final Finder switchTile = find.widgetWithText(
      SwitchListTile,
      'Показывать мой город',
    );
    final SwitchListTile before = tester.widget<SwitchListTile>(switchTile);
    expect(before.value, isFalse);

    await tester.tap(switchTile);
    await tester.pumpAndSettle();

    final SwitchListTile after = tester.widget<SwitchListTile>(switchTile);
    expect(after.value, isTrue);
  });
}
