/// Новость ленты планеты (генерируется ИИ-сервисом).
class PlanetNewsItem {
  const PlanetNewsItem({
    required this.id,
    required this.title,
    required this.summary,
    required this.emoji,
    required this.sourceName,
    required this.tag,
    required this.publishedAt,
    required this.likes,
  });

  final String id;
  final String title;
  final String summary;

  /// Эмодзи-иллюстрация новости.
  final String emoji;

  /// Источник / автор новости.
  final String sourceName;

  /// Тематический тег новости.
  final String tag;

  final DateTime publishedAt;
  final int likes;
}
