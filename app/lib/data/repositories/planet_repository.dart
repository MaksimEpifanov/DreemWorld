import '../models/planet.dart';

/// Репозиторий планет-сообществ по интересам.
abstract class PlanetRepository {
  /// Все доступные планеты.
  List<Planet> getPlanets();

  /// Планета по идентификатору (или `null`, если не найдена).
  Planet? byId(String id);
}
