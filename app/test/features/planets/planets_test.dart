import 'package:dreem_world/core/theme/index.dart';
import 'package:dreem_world/data/providers/planet_providers.dart';
import 'package:dreem_world/features/planets/home/planet_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Планеты', () {
    test('каталог планет не пуст и содержит ключевые сообщества', () {
      final ProviderContainer container = ProviderContainer();
      addTearDown(container.dispose);

      final List<String> ids = container
          .read(planetsProvider)
          .map((dynamic planet) => planet.id as String)
          .toList();

      expect(ids, isNotEmpty);
      expect(ids, contains('p_fishing'));
      expect(ids, contains('p_travel'));
    });

    testWidgets('главный экран отображает планеты', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.of(AppThemeName.neonViolet),
            home: const PlanetHomeScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.textContaining('Планета'), findsWidgets);
    });
  });
}
