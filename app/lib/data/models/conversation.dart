import 'package:freezed_annotation/freezed_annotation.dart';

import 'message.dart';

part 'conversation.freezed.dart';
part 'conversation.g.dart';

/// Диалог между двумя участниками.
@freezed
abstract class Conversation with _$Conversation {
  const factory Conversation({
    required String id,
    required List<String> participantIds,
    Message? lastMessage,
    @Default(0) int unreadCount,
    DateTime? updatedAt,
  }) = _Conversation;

  factory Conversation.fromJson(Map<String, dynamic> json) =>
      _$ConversationFromJson(json);

  const Conversation._();

  /// Есть непрочитанные сообщения.
  bool get hasUnread => unreadCount > 0;

  /// Идентификатор собеседника относительно [currentUserId].
  String otherParticipantId(String currentUserId) => participantIds.firstWhere(
        (String id) => id != currentUserId,
        orElse: () => currentUserId,
      );
}
