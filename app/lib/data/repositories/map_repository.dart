import '../models/map_spot.dart';
import '../models/planet.dart';

/// Репозиторий отметок на карте планеты.
abstract class MapRepository {
  /// Отметки на карте указанной планеты.
  List<MapSpot> spotsFor(Planet planet);
}
