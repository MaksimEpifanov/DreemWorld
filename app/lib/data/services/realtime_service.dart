import '../models/conversation.dart';
import '../models/match.dart';
import '../models/message.dart';
import '../models/profile.dart';

/// Топики реалтайм-событий.
abstract final class RealtimeTopics {
  const RealtimeTopics._();

  static const String matches = 'matches';
  static const String conversations = 'conversations';
  static const String presence = 'presence';

  /// Топик сообщений конкретного диалога.
  static String conversation(String conversationId) =>
      'conversation:$conversationId';

  /// Топик обновлений профиля.
  static String profile(String profileId) => 'profile:$profileId';
}

/// Событие реалтайм-шины.
sealed class RealtimeEvent {
  const RealtimeEvent();

  /// Новое сообщение в чате.
  const factory RealtimeEvent.message({required Message message}) =
      MessageRealtimeEvent;

  /// Диалог обновлён (последнее сообщение, счётчик непрочитанных).
  const factory RealtimeEvent.conversationUpdated({
    required Conversation conversation,
  }) = ConversationUpdatedRealtimeEvent;

  /// Мэтч создан или сменил статус.
  const factory RealtimeEvent.matchUpdated({required Match match}) =
      MatchUpdatedRealtimeEvent;

  /// Профиль обновлён.
  const factory RealtimeEvent.profileUpdated({required Profile profile}) =
      ProfileUpdatedRealtimeEvent;

  /// Собеседник печатает.
  const factory RealtimeEvent.typing({
    required String conversationId,
    required String userId,
  }) = TypingRealtimeEvent;

  /// Изменился статус «онлайн» пользователя.
  const factory RealtimeEvent.presence({
    required String userId,
    required bool isOnline,
  }) = PresenceRealtimeEvent;

  /// Топик события — по нему фильтруются подписки.
  String get topic;
}

/// Событие нового сообщения.
final class MessageRealtimeEvent extends RealtimeEvent {
  const MessageRealtimeEvent({required this.message});

  final Message message;

  @override
  String get topic => RealtimeTopics.conversation(message.conversationId);
}

/// Событие обновления диалога.
final class ConversationUpdatedRealtimeEvent extends RealtimeEvent {
  const ConversationUpdatedRealtimeEvent({required this.conversation});

  final Conversation conversation;

  @override
  String get topic => RealtimeTopics.conversation(conversation.id);
}

/// Событие обновления мэтча.
final class MatchUpdatedRealtimeEvent extends RealtimeEvent {
  const MatchUpdatedRealtimeEvent({required this.match});

  final Match match;

  @override
  String get topic => RealtimeTopics.matches;
}

/// Событие обновления профиля.
final class ProfileUpdatedRealtimeEvent extends RealtimeEvent {
  const ProfileUpdatedRealtimeEvent({required this.profile});

  final Profile profile;

  @override
  String get topic => RealtimeTopics.profile(profile.id);
}

/// Событие «печатает».
final class TypingRealtimeEvent extends RealtimeEvent {
  const TypingRealtimeEvent({
    required this.conversationId,
    required this.userId,
  });

  final String conversationId;
  final String userId;

  @override
  String get topic => RealtimeTopics.conversation(conversationId);
}

/// Событие смены статуса «онлайн».
final class PresenceRealtimeEvent extends RealtimeEvent {
  const PresenceRealtimeEvent({
    required this.userId,
    required this.isOnline,
  });

  final String userId;
  final bool isOnline;

  @override
  String get topic => RealtimeTopics.presence;
}

/// Абстракция реалтайм-канала: [MockRealtimeService] сейчас,
/// `SupabaseRealtimeService` — при подключении бэкенда.
///
/// Шина событий — broadcast [StreamController]: слушатели получают
/// только события после подписки.
abstract interface class RealtimeService {
  /// Все события шины.
  Stream<RealtimeEvent> get events;

  /// Активные подписки на топики.
  Set<String> get topics;

  /// Подписка на топик.
  ///
  /// Если подписок нет — события не фильтруются; иначе наружу проходят
  /// только события с подписанным топиком.
  void subscribe(String topic);

  /// Отписка от топика.
  void unsubscribe(String topic);

  /// Отправка события в шину.
  void emit(RealtimeEvent event);

  /// Закрытие шины.
  Future<void> dispose();
}
