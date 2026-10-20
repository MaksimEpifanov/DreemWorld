import '../models/planet.dart';
import '../models/planet_news.dart';

/// Репозиторий новостной ленты планеты.
///
/// Позже будет обращаться к ИИ-сервису и обновляться раз в час; сейчас —
/// детерминированный мок.
abstract class NewsRepository {
  /// Лента новостей планеты на момент [now].
  ///
  /// При смене часа [now] набор новостей меняется (обновление раз в час).
  List<PlanetNewsItem> newsFor(Planet planet, {required DateTime now});
}
