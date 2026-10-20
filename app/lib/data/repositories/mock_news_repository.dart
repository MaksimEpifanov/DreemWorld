import '../models/planet.dart';
import '../models/planet_news.dart';
import 'news_repository.dart';

/// Мок-репозиторий новостей: генерирует ленту, меняющуюся каждый час.
///
/// Сид строится из идентификатора планеты и номера часа, поэтому в течение
/// одного часа лента стабильна, а с началом нового — обновляется.
class MockNewsRepository implements NewsRepository {
  const MockNewsRepository();

  @override
  List<PlanetNewsItem> newsFor(Planet planet, {required DateTime now}) {
    final int hourBucket = now.millisecondsSinceEpoch ~/ Duration.millisecondsPerHour;
    final int seed = _hash(planet.id) ^ hourBucket;
    final int count = 5 + seed % 3; // 5..7 новостей

    final String tag = planet.keywords.isEmpty ? 'Новости' : planet.keywords.first;
    final List<_NewsTemplate> pool = <_NewsTemplate>[
      ...?_templates[tag],
      ..._generic,
    ];

    return List<PlanetNewsItem>.generate(count, (int i) {
      final _NewsTemplate template = pool[(seed + i * 3) % pool.length];
      final int minutesAgo = 3 + (seed + i * 37) % 57;
      return PlanetNewsItem(
        id: '${planet.id}_news_${hourBucket}_$i',
        title: template.title(planet),
        summary: template.summary(planet),
        emoji: template.emoji,
        sourceName: _sources[(seed + i * 7) % _sources.length],
        tag: tag,
        publishedAt: now.subtract(Duration(minutes: minutesAgo)),
        likes: 3 + (seed + i * 13) % 180,
      );
    }, growable: false);
  }

  static int _hash(String value) {
    int h = 2166136261;
    for (final int code in value.codeUnits) {
      h ^= code;
      h = (h * 16777619) & 0x7fffffff;
    }
    return h;
  }
}

typedef _TextBuilder = String Function(Planet planet);

class _NewsTemplate {
  const _NewsTemplate({
    required this.title,
    required this.summary,
    required this.emoji,
  });

  final _TextBuilder title;
  final _TextBuilder summary;
  final String emoji;
}

const List<String> _sources = <String>[
  'ИИ-редакция Dreem',
  'Сообщество планеты',
  'Куратор интересов',
  'Тренды Dreem',
  'Голосование участников',
];

final List<_NewsTemplate> _generic = <_NewsTemplate>[
  _NewsTemplate(
    title: (Planet p) => 'Дайджест «${p.name}» за последний час',
    summary: (Planet p) =>
        'ИИ собрал самое интересное из мира «${p.name}»: новые истории, '
        'споры и находки участников.',
    emoji: '📰',
  ),
  _NewsTemplate(
    title: (Planet p) => 'Топ-обсуждение часа',
    summary: (Planet p) =>
        'Участники «${p.name}» спорят о лучшем совете недели. '
        'Присоединяйтесь к обсуждению!',
    emoji: '💬',
  ),
  _NewsTemplate(
    title: (Planet p) => 'Новые лица в «${p.name}»',
    summary: (Planet p) =>
        'За последний час к планете присоединились новые участники '
        'с похожими интересами.',
    emoji: '🌟',
  ),
  _NewsTemplate(
    title: (Planet p) => 'Подборка советов от ИИ',
    summary: (Planet p) =>
        'Персональные рекомендации для интересующихся темой '
        '«${p.keywords.isEmpty ? p.name : p.keywords.first}».',
    emoji: '✨',
  ),
  _NewsTemplate(
    title: (Planet p) => 'Итоги голосования планеты',
    summary: (Planet p) =>
        'Сообщество выбрало главную тему дня. Результат уже виден '
        'в рейтинге «${p.name}».',
    emoji: '🏆',
  ),
];

final Map<String, List<_NewsTemplate>> _templates =
    <String, List<_NewsTemplate>>{
  'Природа': <_NewsTemplate>[
    _NewsTemplate(
      title: (Planet p) => 'Сезонные изменения в мире природы',
      summary: (Planet p) =>
          'ИИ отмечает лучшие точки для прогулок на этой неделе — '
          'по данным участников «${p.name}».',
      emoji: '🌿',
    ),
  ],
  'Спорт': <_NewsTemplate>[
    _NewsTemplate(
      title: (Planet p) => 'План тренировок на неделю',
      summary: (Planet p) =>
          'ИИ подготовил программу для участников «${p.name}» — '
          'от новичка до продвинутого.',
      emoji: '🏅',
    ),
  ],
  'Путешествия': <_NewsTemplate>[
    _NewsTemplate(
      title: (Planet p) => 'Маршрут недели от сообщества',
      summary: (Planet p) =>
          'Самый популярный маршрут в «${p.name}»: куда едут '
          'участники прямо сейчас.',
      emoji: '🗺️',
    ),
  ],
  'Кино': <_NewsTemplate>[
    _NewsTemplate(
      title: (Planet p) => 'Премьеры и что смотреть вечером',
      summary: (Planet p) =>
          'ИИ подобрал фильмы по вкусам участников «${p.name}».',
      emoji: '🍿',
    ),
  ],
  'Книги': <_NewsTemplate>[
    _NewsTemplate(
      title: (Planet p) => 'Книга часа',
      summary: (Planet p) =>
          'Самая обсуждаемая книга в «${p.name}» прямо сейчас.',
      emoji: '📖',
    ),
  ],
  'Музыка': <_NewsTemplate>[
    _NewsTemplate(
      title: (Planet p) => 'Плейлист часа',
      summary: (Planet p) =>
          'ИИ собрал треки, которые слушают участники «${p.name}».',
      emoji: '🎧',
    ),
  ],
  'Гейминг': <_NewsTemplate>[
    _NewsTemplate(
      title: (Planet p) => 'Игровые новости и патчи',
      summary: (Planet p) =>
          'Что нового в мире игр — подборка для «${p.name}».',
      emoji: '🎮',
    ),
  ],
  'Еда': <_NewsTemplate>[
    _NewsTemplate(
      title: (Planet p) => 'Рецепт дня',
      summary: (Planet p) =>
          'ИИ выбрал рецепт по вкусам участников «${p.name}».',
      emoji: '🍳',
    ),
  ],
};
