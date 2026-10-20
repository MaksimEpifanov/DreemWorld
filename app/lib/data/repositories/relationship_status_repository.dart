import '../models/relationship_status.dart';

/// Репозиторий статуса отношений участников.
abstract class RelationshipStatusRepository {
  /// Статус отношений участника по его идентификатору.
  RelationshipStatus statusFor(String profileId);
}

/// Мок-репозиторий: статус выводится детерминированно из идентификатора.
class MockRelationshipStatusRepository implements RelationshipStatusRepository {
  const MockRelationshipStatusRepository();

  @override
  RelationshipStatus statusFor(String profileId) {
    if (profileId.isEmpty) return RelationshipStatus.unspecified;
    final List<RelationshipStatus> values = RelationshipStatus.values;
    return values[_hash(profileId) % values.length];
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
