/// Причина жалобы на пользователя.
///
/// [severity] — «вес» нарушения (0..3), используется заглушкой модерации
/// и ИИ-фильтром для авто-действий (например, мгновенного скрытия).
enum ReportReason {
  spam('Спам или реклама', '📢', 1),
  scam('Мошенничество', '💸', 3),
  harassment('Оскорбления или травля', '😡', 2),
  sexualContent('Сексуальный контент', '🔞', 3),
  minorSafety('Угроза безопасности несовершеннолетнего', '🛡️', 3),
  violence('Угрозы или насилие', '⚠️', 3),
  fakeProfile('Фальшивый профиль', '🎭', 1),
  other('Другое', '❓', 1);

  const ReportReason(this.label, this.emoji, this.severity);

  final String label;
  final String emoji;
  final int severity;
}

/// Статус рассмотрения жалобы (демо-конвейер модерации).
enum ReportStatus {
  /// Отправлена, ждёт автоматической проверки.
  submitted('Отправлена', '📨'),

  /// На проверке модератором.
  underReview('На проверке', '🔎'),

  /// Принята, меры применены.
  actionTaken('Принята', '✅'),

  /// Отклонена (нарушение не подтвердилось).
  dismissed('Отклонена', '🚫');

  const ReportStatus(this.label, this.emoji);

  final String label;
  final String emoji;
}

/// Что за объект/пользователь, на который жалуются.
enum ReportTarget {
  user('Профиль', '👤'),
  message('Сообщение', '💬'),
  profilePhoto('Фото профиля', '🖼️'),
  planetSpot('Отметка на карте', '📍');

  const ReportTarget(this.label, this.emoji);

  final String label;
  final String emoji;
}

/// Жалоба на пользователя или контент.
class Report {
  const Report({
    required this.id,
    required this.targetId,
    required this.targetName,
    required this.target,
    required this.reason,
    this.comment = '',
    required this.createdAt,
    this.status = ReportStatus.submitted,
    this.autoHidden = false,
  });

  /// Уникальный идентификатор жалобы.
  final String id;

  /// Идентификатор нарушителя/объекта.
  final String targetId;

  /// Отображаемое имя нарушителя/объекта.
  final String targetName;

  /// Тип объекта жалобы.
  final ReportTarget target;

  /// Причина жалобы.
  final ReportReason reason;

  /// Свободный комментарий пользователя.
  final String comment;

  /// Когда отправлена.
  final DateTime createdAt;

  /// Текущий статус рассмотрения.
  final ReportStatus status;

  /// Скрыт ли объект автоматически (ИИ-фильтр / высокий приоритет).
  final bool autoHidden;

  Report copyWith({ReportStatus? status, bool? autoHidden}) {
    return Report(
      id: id,
      targetId: targetId,
      targetName: targetName,
      target: target,
      reason: reason,
      comment: comment,
      createdAt: createdAt,
      status: status ?? this.status,
      autoHidden: autoHidden ?? this.autoHidden,
    );
  }
}

/// Заблокированный пользователь.
class BlockedUser {
  const BlockedUser({
    required this.userId,
    required this.name,
    required this.blockedAt,
    this.reason,
  });

  final String userId;
  final String name;
  final DateTime blockedAt;
  final String? reason;
}
