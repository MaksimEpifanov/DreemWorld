import 'dart:ui' show Color;

import '../models/planet.dart';
import 'planet_repository.dart';

/// Мок-репозиторий планет с предзаполненным каталогом сообществ.
class MockPlanetRepository implements PlanetRepository {
  const MockPlanetRepository();

  @override
  List<Planet> getPlanets() => planets;

  @override
  Planet? byId(String id) {
    for (final Planet planet in planets) {
      if (planet.id == id) return planet;
    }
    return null;
  }

  /// Каталог планет-сообществ.
  static const List<Planet> planets = <Planet>[
    Planet(
      id: 'p_fishing',
      name: 'Планета рыбалки',
      tagline: 'Озёра, реки и большой улов',
      description:
          'Тихие рассветы у воды, старые удочки и рыбацкие истории. '
          'Здесь собираются те, для кого рыбалка — это покой и азарт.',
      emoji: '🎣',
      scene: PlanetScene.fishing,
      primary: Color(0xFF0A6E8A),
      secondary: Color(0xFF12C2C2),
      accent: Color(0xFF6EF3D6),
      memberCount: 1284,
      keywords: <String>['Природа', 'Спорт', 'Путешествия'],
    ),
    Planet(
      id: 'p_travel',
      name: 'Планета путешествий',
      tagline: 'Новые города и далёкие страны',
      description:
          'Архитектура, достопримечательности и дороги, что ведут к мечте. '
          'Сообщество для тех, кто живёт путешествиями.',
      emoji: '✈️',
      scene: PlanetScene.travel,
      primary: Color(0xFFFF7A00),
      secondary: Color(0xFFFFC24B),
      accent: Color(0xFFFF3D8B),
      memberCount: 3421,
      keywords: <String>['Путешествия', 'Природа', 'Фотография'],
    ),
    Planet(
      id: 'p_gaming',
      name: 'Планета геймеров',
      tagline: 'Кооп, рейды и вечерние катки',
      description:
          'Соберите команду, обсудите свежий релиз и найдите союзников '
          'для вечерних игровых сессий.',
      emoji: '🎮',
      scene: PlanetScene.gaming,
      primary: Color(0xFF7C4DFF),
      secondary: Color(0xFF00E5FF),
      accent: Color(0xFFFF2EDB),
      memberCount: 2765,
      keywords: <String>['Игры', 'Технологии'],
    ),
    Planet(
      id: 'p_music',
      name: 'Планета музыки',
      tagline: 'Концерты, плейлисты и джемы',
      description:
          'От инди до классики. Найдите тех, кто услышит ваш вкус, '
          'сходите на концерт или соберите плейлист вместе.',
      emoji: '🎵',
      scene: PlanetScene.music,
      primary: Color(0xFFFF2E88),
      secondary: Color(0xFFB14DFF),
      accent: Color(0xFF00E5FF),
      memberCount: 1988,
      keywords: <String>['Музыка', 'Искусство'],
    ),
    Planet(
      id: 'p_sports',
      name: 'Планета спорта',
      tagline: 'Тренировки, матчи и рекорды',
      description:
          'Спутники по бегу, залу и командным видам спорта. '
          'Мотивируйте друг друга и держите форму.',
      emoji: '⚽',
      scene: PlanetScene.sports,
      primary: Color(0xFF12B76A),
      secondary: Color(0xFF9BE15D),
      accent: Color(0xFF00E0B8),
      memberCount: 2410,
      keywords: <String>['Спорт', 'Фитнес'],
    ),
    Planet(
      id: 'p_food',
      name: 'Планета кулинаров',
      tagline: 'Рецепты, вкусы и уютные ужины',
      description:
          'Готовьте вместе, делитесь рецептами и находите тех, '
          'для кого еда — это язык любви.',
      emoji: '🍜',
      scene: PlanetScene.food,
      primary: Color(0xFFFF8A3D),
      secondary: Color(0xFFFFD166),
      accent: Color(0xFFFF4D6D),
      memberCount: 1567,
      keywords: <String>['Кулинария', 'Путешествия'],
    ),
    Planet(
      id: 'p_art',
      name: 'Планета художников',
      tagline: 'Краски, свет и вдохновение',
      description:
          'Место для художников, фотографов и всех, кто создаёт. '
          'Показывайте работы и находите единомышленников.',
      emoji: '🎨',
      scene: PlanetScene.art,
      primary: Color(0xFFD500F9),
      secondary: Color(0xFF7C4DFF),
      accent: Color(0xFF00E5FF),
      memberCount: 1320,
      keywords: <String>['Искусство', 'Фотография', 'Музыка'],
    ),
    Planet(
      id: 'p_space',
      name: 'Планета космоса',
      tagline: 'Звёзды, наука и мечты о Марсе',
      description:
          'Для влюблённых в небо и науку. Обсуждайте запуски, '
          'телескопы и всё, что выше облаков.',
      emoji: '🚀',
      scene: PlanetScene.space,
      primary: Color(0xFF3D5AFE),
      secondary: Color(0xFF00E5FF),
      accent: Color(0xFFB388FF),
      memberCount: 984,
      keywords: <String>['Технологии', 'Книги', 'Природа'],
    ),
  ];
}
