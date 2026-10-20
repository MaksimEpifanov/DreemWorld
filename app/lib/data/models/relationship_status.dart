/// Статус отношений участника (что показывается в подборе).
enum RelationshipStatus {
  /// В активном поиске партнёра.
  activelyLooking('В активном поиске', '🔍'),

  /// Открыт(а) к знакомствам.
  open('Открыт(а) к общению', '💬'),

  /// Ищет друзей.
  friends('Ищет друзей', '🤝'),

  /// В отношениях.
  inRelationship('В отношениях', '💞'),

  /// Состоит в браке.
  married('Женат(а)', '💍'),

  /// Предпочитает не указывать.
  unspecified('Не указано', '❔');

  const RelationshipStatus(this.label, this.emoji);

  final String label;
  final String emoji;
}
