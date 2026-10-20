import '../models/safety.dart';

/// Результат проверки текста ИИ-фильтром (заглушка модерации).
class ModerationVerdict {
  const ModerationVerdict({
    this.flagged = false,
    this.reasons = const <ReportReason>[],
    this.matched = const <String>[],
  });

  /// Чисто ли сообщение.
  final bool flagged;

  /// Сработавшие категории нарушения.
  final List<ReportReason> reasons;

  /// Совпавшие фрагменты (для отладки/подсветки).
  final List<String> matched;

  /// Человекочитаемое пояснение для пользователя.
  String get message {
    if (!flagged) return 'Запрещённых фрагментов не найдено.';
    return 'Обнаружено: ${reasons.map((ReportReason r) => r.label).join(', ')}';
  }
}

/// Сервис автоматической проверки контента.
///
/// Это **заглушка** на месте реального ИИ (в будущем — модель модерации
/// на сервере). Реализована на простых словарях-паттернах и не требует сети.
abstract class ModerationService {
  /// Проверяет произвольный текст (сообщение, «о себе», комментарий).
  ModerationVerdict checkText(String text);

  /// Проверяет имя/ник на явные нарушения.
  ModerationVerdict checkName(String name);
}

/// Мок-реализация ИИ-фильтра на словарях-паттернах.
class MockModerationService implements ModerationService {
  const MockModerationService();

  static const List<String> _scam = <String>[
    'переведи на карту',
    'скинь денег',
    'криптовалют',
    'быстрый заработок',
    'инвестируй',
    'продам аккаунт',
    'дай данные карты',
    'номер карты и cvv',
  ];

  static const List<String> _sexual = <String>[
    'интим',
    'эскорт',
    'секс за',
    '18+ только',
    'нюд',
  ];

  static const List<String> _harassment = <String>[
    'убью',
    'ненавижу тебя',
    'ты никчё',
    'ты никчемный',
    'заткнись',
    'дебил',
    'идиот',
    'тупой',
  ];

  static const List<String> _minorSafety = <String>[
    'сколько тебе лет, детка',
    'скинь фото без',
    'встретимся тайно',
  ];

  @override
  ModerationVerdict checkText(String text) {
    final String haystack = text.toLowerCase();
    final Set<ReportReason> reasons = <ReportReason>{};
    final List<String> matched = <String>[];

    void scan(List<String> patterns, ReportReason reason) {
      for (final String pattern in patterns) {
        if (haystack.contains(pattern)) {
          reasons.add(reason);
          matched.add(pattern);
        }
      }
    }

    scan(_scam, ReportReason.scam);
    scan(_sexual, ReportReason.sexualContent);
    scan(_harassment, ReportReason.harassment);
    scan(_minorSafety, ReportReason.minorSafety);

    if (haystack.contains('http://') || haystack.contains('https://')) {
      reasons.add(ReportReason.spam);
      matched.add('ссылка');
    }

    return ModerationVerdict(
      flagged: reasons.isNotEmpty,
      reasons: reasons.toList(growable: false),
      matched: matched,
    );
  }

  @override
  ModerationVerdict checkName(String name) {
    final String haystack = name.toLowerCase();
    final bool bad = haystack.contains('admin') ||
        haystack.contains('support') ||
        haystack.contains('модератор');
    return ModerationVerdict(
      flagged: bad,
      reasons: bad ? const <ReportReason>[ReportReason.fakeProfile] : const <ReportReason>[],
      matched: bad ? <String>[name] : const <String>[],
    );
  }
}
