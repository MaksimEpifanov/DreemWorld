import 'package:freezed_annotation/freezed_annotation.dart';

part 'interest.freezed.dart';
part 'interest.g.dart';

/// Категория интереса — группировка для подбора и UI.
@JsonEnum()
enum InterestCategory {
  @JsonValue('music')
  music,
  @JsonValue('sport')
  sport,
  @JsonValue('travel')
  travel,
  @JsonValue('food')
  food,
  @JsonValue('art')
  art,
  @JsonValue('tech')
  tech,
  @JsonValue('science')
  science,
  @JsonValue('games')
  games,
  @JsonValue('cinema')
  cinema,
  @JsonValue('books')
  books,
  @JsonValue('nature')
  nature,
  @JsonValue('fashion')
  fashion,
  @JsonValue('fitness')
  fitness,
  @JsonValue('languages')
  languages,
  @JsonValue('other')
  other;
}

/// Увлечение пользователя.
@freezed
abstract class Interest with _$Interest {
  const factory Interest({
    required String id,
    required String name,
    String? emoji,
    @Default(InterestCategory.other) InterestCategory category,
  }) = _Interest;

  factory Interest.fromJson(Map<String, dynamic> json) =>
      _$InterestFromJson(json);
}

/// Каталог интересов для онбординга и подбора.
abstract final class InterestCatalog {
  const InterestCatalog._();

  static const Interest music = Interest(
    id: 'i_music',
    name: 'Музыка',
    emoji: '🎵',
    category: InterestCategory.music,
  );
  static const Interest travel = Interest(
    id: 'i_travel',
    name: 'Путешествия',
    emoji: '✈️',
    category: InterestCategory.travel,
  );
  static const Interest sport = Interest(
    id: 'i_sport',
    name: 'Спорт',
    emoji: '🏃',
    category: InterestCategory.sport,
  );
  static const Interest art = Interest(
    id: 'i_art',
    name: 'Искусство',
    emoji: '🎨',
    category: InterestCategory.art,
  );
  static const Interest tech = Interest(
    id: 'i_tech',
    name: 'Технологии',
    emoji: '💻',
    category: InterestCategory.tech,
  );
  static const Interest food = Interest(
    id: 'i_food',
    name: 'Кулинария',
    emoji: '🍜',
    category: InterestCategory.food,
  );
  static const Interest cinema = Interest(
    id: 'i_cinema',
    name: 'Кино',
    emoji: '🎬',
    category: InterestCategory.cinema,
  );
  static const Interest books = Interest(
    id: 'i_books',
    name: 'Книги',
    emoji: '📚',
    category: InterestCategory.books,
  );
  static const Interest games = Interest(
    id: 'i_games',
    name: 'Игры',
    emoji: '🎮',
    category: InterestCategory.games,
  );
  static const Interest nature = Interest(
    id: 'i_nature',
    name: 'Природа',
    emoji: '🌲',
    category: InterestCategory.nature,
  );
  static const Interest photography = Interest(
    id: 'i_photo',
    name: 'Фотография',
    emoji: '📷',
    category: InterestCategory.art,
  );
  static const Interest fitness = Interest(
    id: 'i_fitness',
    name: 'Фитнес',
    emoji: '💪',
    category: InterestCategory.fitness,
  );

  /// Все доступные интересы.
  static const List<Interest> all = <Interest>[
    music,
    travel,
    sport,
    art,
    tech,
    food,
    cinema,
    books,
    games,
    nature,
    photography,
    fitness,
  ];
}
