import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dreem_world/core/theme/index.dart';
import 'package:dreem_world/features/shell/app_shell.dart';

void main() {
  group('AppNavigationBar', () {
    testWidgets('рендерит четыре вкладки и сообщает выбранный индекс', (
      WidgetTester tester,
    ) async {
      int selected = 0;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.of(AppThemeName.neonViolet),
          home: Scaffold(
            bottomNavigationBar: AppNavigationBar(
              currentIndex: selected,
              onDestinationSelected: (int index) => selected = index,
            ),
          ),
        ),
      );

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.text('Главная'), findsOneWidget);
      expect(find.text('Подбор'), findsOneWidget);
      expect(find.text('Чаты'), findsOneWidget);
      expect(find.text('Контакты'), findsOneWidget);
      expect(find.byType(NavigationDestination), findsNWidgets(4));

      await tester.tap(find.text('Чаты'));
      await tester.pumpAndSettle();
      expect(selected, 2);

      await tester.tap(find.text('Контакты'));
      await tester.pumpAndSettle();
      expect(selected, 3);
    });
  });
}
