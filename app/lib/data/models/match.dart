import 'package:freezed_annotation/freezed_annotation.dart';

part 'match.freezed.dart';
part 'match.g.dart';

/// Статус мэтча.
@JsonEnum()
enum MatchStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('liked')
  liked,
  @JsonValue('passed')
  passed,
  @JsonValue('active')
  active,
  @JsonValue('unmatched')
  unmatched;
}

/// Односторонняя или взаимная симпатия.
@freezed
abstract class Match with _$Match {
  const factory Match({
    required String id,
    required String user1Id,
    required String user2Id,
    @Default(0) int compatibility,
    @Default(MatchStatus.pending) MatchStatus status,
    DateTime? matchedAt,
    DateTime? createdAt,
  }) = _Match;

  factory Match.fromJson(Map<String, dynamic> json) => _$MatchFromJson(json);

  const Match._();

  /// Идентификатор собеседника относительно [currentUserId].
  String otherUserId(String currentUserId) =>
      user1Id == currentUserId ? user2Id : user1Id;

  /// Мэтч уже взаимный.
  bool get isActive => status == MatchStatus.active;
}
