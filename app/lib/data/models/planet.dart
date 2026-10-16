import 'dart:ui' show Color;

/// Визуальная сцена (тема оформления) планеты-сообщества.
///
/// Определяет, какими элементами оформлен «внутренний мир» планеты:
/// водой, достопримечательностями, нотами, пикселями и т.д.
enum PlanetScene {
  fishing,
  travel,
  gaming,
  music,
  sports,
  food,
  art,
  space,
}

/// Планета-сообщество по интересам.
///
/// Маленькое «сообщество» людей с общим увлечением со своим визуальным
/// оформлением и подборкой участников.
class Planet {
  const Planet({
    required this.id,
    required this.name,
    required this.tagline,
    required this.description,
    required this.emoji,
    required this.scene,
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.memberCount,
    required this.keywords,
  });

  final String id;
  final String name;

  /// Короткий слоган под названием.
  final String tagline;

  /// Подробное описание планеты.
  final String description;

  final String emoji;
  final PlanetScene scene;

  final Color primary;
  final Color secondary;
  final Color accent;

  final int memberCount;

  /// Ключевые интересы планеты (по ним подбираются участники).
  final List<String> keywords;

  @override
  bool operator ==(Object other) => other is Planet && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
