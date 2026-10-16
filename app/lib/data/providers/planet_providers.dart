import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/planet.dart';
import '../models/profile.dart';
import '../repositories/mock_planet_repository.dart';
import '../repositories/planet_repository.dart';
import 'app_providers.dart';

/// Репозиторий планет-сообществ.
final Provider<PlanetRepository> planetRepositoryProvider =
    Provider<PlanetRepository>((Ref ref) => const MockPlanetRepository());

/// Каталог планет.
final Provider<List<Planet>> planetsProvider = Provider<List<Planet>>(
  (Ref ref) => ref.watch(planetRepositoryProvider).getPlanets(),
);

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
