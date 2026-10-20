import 'package:dreem_world/core/theme/index.dart';
import 'package:dreem_world/data/models/map_spot.dart';
import 'package:dreem_world/data/models/planet.dart';
import 'package:dreem_world/data/providers/planet_providers.dart';
import 'package:dreem_world/features/planets/home/planet_home_screen.dart';
import 'package:dreem_world/features/planets/map/planet_map_screen.dart';
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
      expect(ids.length, 22);
      expect(ids, contains('p_fishing'));
      expect(ids, contains('p_travel'));
      expect(ids, contains('p_cinema'));
      expect(ids, contains('p_books'));
      expect(ids, contains('p_collecting'));
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

  group('Карта планеты', () {
    test('для планеты генерируются отметки с координатами и тегами', () {
      final ProviderContainer container = ProviderContainer();
      addTearDown(container.dispose);

      final Planet planet = container.read(planetByIdProvider('p_fishing'))!;
      final List<MapSpot> spots =
          container.read(planetMapSpotsProvider('p_fishing'));

      expect(spots.length, greaterThanOrEqualTo(6));
      for (final MapSpot spot in spots) {
        expect(spot.x, inInclusiveRange(0, 1));
        expect(spot.y, inInclusiveRange(0, 1));
        expect(spot.tags, isNotEmpty);
        expect(spot.title, isNotEmpty);
      }
      // Отметки привязаны к интересам планеты.
      expect(
        spots.any(
          (MapSpot spot) => spot.tags.any(planet.keywords.contains),
        ),
        isTrue,
      );
    });

    testWidgets('экран карты показывает отметки и теги', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.of(AppThemeName.neonViolet),
            home: const PlanetMapScreen(planetId: 'p_fishing'),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.textContaining('отметок участников'), findsOneWidget);
      expect(find.textContaining('Отметить место'), findsOneWidget);
    });
  });
}
