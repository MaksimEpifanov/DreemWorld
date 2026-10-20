import 'package:dreem_world/core/theme/index.dart';
import 'package:dreem_world/data/models/map_spot.dart';
import 'package:dreem_world/data/models/planet.dart';
import 'package:dreem_world/data/models/planet_news.dart';
import 'package:dreem_world/data/providers/planet_providers.dart';
import 'package:dreem_world/data/repositories/mock_news_repository.dart';
import 'package:dreem_world/data/repositories/mock_planet_repository.dart';
import 'package:dreem_world/features/planets/cosmos/orbital_catalog.dart';
import 'package:dreem_world/features/planets/cosmos/realistic_planet.dart';
import 'package:dreem_world/features/planets/cosmos/realistic_sun.dart';
import 'package:dreem_world/features/planets/home/planet_home_screen.dart';
import 'package:dreem_world/features/planets/map/planet_map_screen.dart';
import 'package:dreem_world/features/planets/news/planet_news_screen.dart';
import 'package:dreem_world/features/planets/news/widgets/news_card.dart';
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

  group('Новости планеты', () {
    test('лента не пуста и обновляется при смене часа', () {
      const MockNewsRepository repo = MockNewsRepository();
      final ProviderContainer container = ProviderContainer();
      addTearDown(container.dispose);
      final Planet planet = container.read(planetByIdProvider('p_fishing'))!;

      final DateTime h1 = DateTime(2026, 1, 1, 10, 5);
      final DateTime h2 = DateTime(2026, 1, 1, 11, 5);

      final List<PlanetNewsItem> a = repo.newsFor(planet, now: h1);
      final List<PlanetNewsItem> b = repo.newsFor(planet, now: h1);
      final List<PlanetNewsItem> c = repo.newsFor(planet, now: h2);

      expect(a, isNotEmpty);
      // В течение одного часа лента стабильна.
      expect(
        a.map((PlanetNewsItem n) => n.id),
        equals(b.map((PlanetNewsItem n) => n.id)),
      );
      // В новый час — другая лента.
      expect(
        a.map((PlanetNewsItem n) => n.id),
        isNot(equals(c.map((PlanetNewsItem n) => n.id))),
      );
      expect(a.first.tag, planet.keywords.first);
    });

    testWidgets('экран новостей показывает ленту', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.of(AppThemeName.neonViolet),
            home: const PlanetNewsScreen(planetId: 'p_fishing'),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.textContaining('обновляется каждый час'), findsOneWidget);
      expect(find.byType(NewsCard), findsWidgets);
    });
  });

  group('Орбитальный каталог', () {
    testWidgets('каталог рисует солнце и планеты вокруг него', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final List<Planet> planets = const MockPlanetRepository().getPlanets();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.of(AppThemeName.neonViolet),
          home: Scaffold(
            body: OrbitalCatalog(
              planets: planets,
              onPlanetTap: (Planet planet) {},
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.byType(RealisticSun), findsOneWidget);
      expect(find.byType(RealisticPlanet), findsWidgets);
    });

    testWidgets('каждая планета обёрнута в обработчик нажатия', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final List<Planet> planets = const MockPlanetRepository().getPlanets();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.of(AppThemeName.neonViolet),
          home: Scaffold(
            body: OrbitalCatalog(
              planets: planets,
              onPlanetTap: (Planet planet) {},
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pumpAndSettle();

      expect(
        find.byType(GestureDetector),
        findsAtLeastNWidgets(planets.length),
      );
    });
  });
}
