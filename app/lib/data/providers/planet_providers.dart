import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/map_spot.dart';
import '../models/planet.dart';
import '../models/planet_news.dart';
import '../models/profile.dart';
import '../repositories/map_repository.dart';
import '../repositories/mock_map_repository.dart';
import '../repositories/mock_news_repository.dart';
import '../repositories/mock_planet_repository.dart';
import '../repositories/news_repository.dart';
import '../repositories/planet_repository.dart';
import 'app_providers.dart';

/// Репозиторий планет-сообществ.
final Provider<PlanetRepository> planetRepositoryProvider =
    Provider<PlanetRepository>((Ref ref) => const MockPlanetRepository());

/// Репозиторий отметок на карте планет.
final Provider<MapRepository> mapRepositoryProvider =
    Provider<MapRepository>((Ref ref) => const MockMapRepository());

/// Репозиторий новостной ленты планет.
final Provider<NewsRepository> newsRepositoryProvider =
    Provider<NewsRepository>((Ref ref) => const MockNewsRepository());

/// Каталог планет.
final Provider<List<Planet>> planetsProvider = Provider<List<Planet>>(
  (Ref ref) => ref.watch(planetRepositoryProvider).getPlanets(),
);

/// Избранные планеты на главной (до 7).
///
/// Если в профиле есть интересы — берём планеты, подходящие по ключевым
/// словам. Если совпадений нет (или профиль ещё не загружен) — первые 7.
final Provider<List<Planet>> featuredPlanetsProvider = Provider<List<Planet>>((
  Ref ref,
) {
  final List<Planet> all = ref.watch(planetsProvider);
  final List<String> interests =
      ref.watch(currentProfileProvider).valueOrNull?.interestNames ??
      const <String>[];
  if (interests.isEmpty) {
    return all.take(7).toList(growable: false);
  }
  final List<Planet> matched = all
      .where((Planet planet) => planet.keywords.any(interests.contains))
      .toList(growable: false);
  return (matched.isEmpty ? all : matched).take(7).toList(growable: false);
});

/// Планеты «других интересов» — всё, что не попало в избранные (до 4).
final Provider<List<Planet>> otherPlanetsProvider = Provider<List<Planet>>((
  Ref ref,
) {
  final List<Planet> all = ref.watch(planetsProvider);
  final Set<String> featured = ref
      .watch(featuredPlanetsProvider)
      .map((Planet planet) => planet.id)
      .toSet();
  return all
      .where((Planet planet) => !featured.contains(planet.id))
      .toList(growable: false);
});

/// Планета по идентификатору.
final ProviderFamily<Planet?, String> planetByIdProvider =
    Provider.family<Planet?, String>(
      (Ref ref, String id) => ref.watch(planetRepositoryProvider).byId(id),
    );

/// Участники планеты — подвыборка каталога подбора по общим интересам.
///
/// Если по интересам никто не нашёлся, возвращается весь каталог, чтобы
/// планета не оставалась пустой.
final ProviderFamily<AsyncValue<List<Profile>>, String> planetMembersProvider =
    Provider.family<AsyncValue<List<Profile>>, String>((Ref ref, String id) {
  final Planet? planet = ref.watch(planetByIdProvider(id));
  final AsyncValue<List<Profile>> profiles = ref.watch(
    discoveryProfilesProvider,
  );

  if (planet == null) {
    return const AsyncValue<List<Profile>>.data(<Profile>[]);
  }

  return profiles.whenData((List<Profile> all) {
    final List<Profile> matched = all
        .where(
          (Profile profile) =>
              profile.interestNames.any(planet.keywords.contains),
        )
        .toList(growable: false);
    return matched.isEmpty ? all : matched;
  });
});

/// Отметки на карте планеты.
final ProviderFamily<List<MapSpot>, String> planetMapSpotsProvider =
    Provider.family<List<MapSpot>, String>((Ref ref, String id) {
  final Planet? planet = ref.watch(planetByIdProvider(id));
  if (planet == null) return const <MapSpot>[];
  return ref.watch(mapRepositoryProvider).spotsFor(planet);
});

/// Лента новостей планеты с обновлением раз в час.
///
/// Первый выпуск отдаётся сразу, затем лента пересобирается каждый час.
final StreamProviderFamily<List<PlanetNewsItem>, String> planetNewsProvider =
    StreamProvider.family<List<PlanetNewsItem>, String>((Ref ref, String id) {
  final Planet? planet = ref.watch(planetByIdProvider(id));
  if (planet == null) {
    return Stream<List<PlanetNewsItem>>.value(const <PlanetNewsItem>[]);
  }

  final NewsRepository repository = ref.watch(newsRepositoryProvider);
  return _hourlyNews(repository, planet);
});

/// Бесконечный поток новостей: сразу первая порция, далее раз в час.
///
/// Поток отменяет таймер при закрытии подписки (например, при уходе с
/// экрана), поэтому не оставляет «висящих» таймеров.
Stream<List<PlanetNewsItem>> _hourlyNews(
  NewsRepository repository,
  Planet planet,
) {
  StreamController<List<PlanetNewsItem>>? controller;
  Timer? timer;

  void emit() =>
      controller?.add(repository.newsFor(planet, now: DateTime.now()));

  controller = StreamController<List<PlanetNewsItem>>(
    onListen: () {
      emit();
      timer = Timer.periodic(const Duration(hours: 1), (_) => emit());
    },
    onCancel: () {
      timer?.cancel();
      timer = null;
    },
  );

  return controller.stream;
}
