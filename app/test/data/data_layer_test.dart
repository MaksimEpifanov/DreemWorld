import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dreem_world/data/models/conversation.dart';
import 'package:dreem_world/data/models/interest.dart';
import 'package:dreem_world/data/models/match.dart';
import 'package:dreem_world/data/models/message.dart';
import 'package:dreem_world/data/models/profile.dart';
import 'package:dreem_world/data/models/user.dart';
import 'package:dreem_world/data/providers/app_providers.dart';
import 'package:dreem_world/data/repositories/mock_chat_repository.dart';
import 'package:dreem_world/data/repositories/mock_match_repository.dart';
import 'package:dreem_world/data/repositories/mock_profile_repository.dart';
import 'package:dreem_world/data/services/mock_ai_service.dart';
import 'package:dreem_world/data/services/mock_realtime_service.dart';
import 'package:dreem_world/data/services/realtime_service.dart';

void main() {
  group('JSON-сериализация моделей', () {
    test('Interest и Profile проходят roundtrip', () {
      final Profile profile = MockProfileRepository.seedProfiles[1];
      final Profile restored =
          Profile.fromJson(profile.toJson());

      expect(restored, profile);
      expect(restored.interests.first.category, isA<InterestCategory>());
      expect(restored.interestNames, isNotEmpty);
    });

    test('Message проходят roundtrip с переводом', () {
      final Message message = Message(
        id: 'm1',
        conversationId: 'c1',
        senderId: 'p_anna',
        text: 'Hello',
        translatedText: 'Привет',
        translatedTo: 'ru',
        isRead: true,
        status: MessageStatus.read,
        createdAt: DateTime.utc(2026, 1, 1),
      );
      final Message restored =
          Message.fromJson(message.toJson());

      expect(restored, message);
      expect(restored.isTranslated, isTrue);
      expect(restored.displayText, 'Привет');
    });

    test('Match, User и Conversation проходят roundtrip', () {
      final Match match = Match(
        id: 'm1',
        user1Id: 'me',
        user2Id: 'p_anna',
        compatibility: 87,
        status: MatchStatus.active,
        createdAt: DateTime.utc(2026, 1, 1),
      );
      expect(Match.fromJson(match.toJson()), match);
      expect(match.otherUserId('me'), 'p_anna');
      expect(match.isActive, isTrue);

      final User user = User(id: 'u1', name: 'Анна', age: 24);
      expect(User.fromJson(user.toJson()), user);

      final Conversation conversation = Conversation(
        id: 'c1',
        participantIds: const <String>['me', 'p_anna'],
        lastMessage: Message(
          id: 'm1',
          conversationId: 'c1',
          senderId: 'p_anna',
          text: 'hi',
        ),
        unreadCount: 2,
        updatedAt: DateTime.utc(2026, 1, 1),
      );
      final Conversation restoredConversation = Conversation.fromJson(
        conversation.toJson(),
      );
      expect(restoredConversation, conversation);
      expect(restoredConversation.hasUnread, isTrue);
      expect(restoredConversation.otherParticipantId('me'), 'p_anna');
    });
  });

  group('MockAiService', () {
    const MockAiService ai = MockAiService();
    final Profile me = MockProfileRepository.seedProfiles[0];
    final Profile anna = MockProfileRepository.seedProfiles[1];

    test('совместимость в диапазоне 0..100 и детерминирована', () async {
      final int first = await ai.computeCompatibility(me, anna);
      final int second = await ai.computeCompatibility(me, anna);

      expect(first, inInclusiveRange(0, 100));
      expect(first, second);
      expect(await ai.computeCompatibility(me, me), greaterThan(60));
    });

    test('предлагает темы на основе общих интересов', () async {
      final List<String> topics = await ai.suggestTopics(me, anna);

      expect(topics, isNotEmpty);
      expect(topics.length, lessThanOrEqualTo(5));
      expect(topics.first, contains('Путешествия'));
    });

    test('перевод помечает целевой язык', () async {
      expect(await ai.translate('Привет', 'en'), '[en] Привет');
      expect(await ai.translate('   ', 'en'), '   ');
    });
  });

  group('MockRealtimeService', () {
    test('доставляет события подписчикам и фильтрует по топику', () async {
      final MockRealtimeService service = MockRealtimeService();
      final List<RealtimeEvent> received = <RealtimeEvent>[];
      final StreamSubscription<RealtimeEvent> sub =
          service.events.listen(received.add);

      service.subscribe(RealtimeTopics.presence);
      service.emit(RealtimeEvent.presence(userId: 'u1', isOnline: true));
      service.emit(
        RealtimeEvent.matchUpdated(
          match: MockMatchRepository.seedMatches.first,
        ),
      );
      await Future<void>.delayed(Duration.zero);

      expect(service.topics, contains(RealtimeTopics.presence));
      expect(received, hasLength(1));
      expect(received.single.topic, RealtimeTopics.presence);

      await sub.cancel();
      await service.dispose();
    });
  });

  group('MockProfileRepository', () {
    test('каталог подбора исключает текущего пользователя', () async {
      final MockProfileRepository repository = MockProfileRepository();
      final List<Profile> profiles = await repository.getDiscoveryProfiles();

      expect(profiles, hasLength(MockProfileRepository.seedProfiles.length - 1));
      expect(profiles.map((Profile p) => p.id), isNot(contains('me')));

      final Profile? me = await repository.getCurrentProfile();
      expect(me?.id, 'me');

      repository.dispose();
    });
  });

  group('MockProfileRepository сохранение профиля', () {
    test('без сохранённого профиля использует сид-данные', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final MockProfileRepository repository = MockProfileRepository();
      addTearDown(repository.dispose);

      expect(await repository.hasSavedProfileAsync(), isFalse);
      expect((await repository.getCurrentProfile())?.name, 'Ты');
    });

    test('сохраняет и восстанавливает текущий профиль между запусками',
        () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});

      final MockProfileRepository first = MockProfileRepository();
      final Profile? original = await first.getCurrentProfile();
      expect(original, isNotNull);

      final Profile updated = original!.copyWith(
        name: 'Сохранённый',
        city: 'Казань',
        photoUrl: 'data:image/jpeg;base64,AAAA',
      );
      await first.saveProfile(updated);
      expect(first.hasSavedProfile, isTrue);
      first.dispose();

      final MockProfileRepository second = MockProfileRepository();
      addTearDown(second.dispose);
      final Profile? restored = await second.getCurrentProfile();

      expect(restored, isNotNull);
      expect(restored!.name, 'Сохранённый');
      expect(restored.city, 'Казань');
      expect(restored.photoUrl, 'data:image/jpeg;base64,AAAA');
      expect(await second.hasSavedProfileAsync(), isTrue);
    });
  });

  group('MockMatchRepository', () {
    late MockProfileRepository profiles;
    late MockMatchRepository matches;

    setUp(() {
      profiles = MockProfileRepository();
      matches = MockMatchRepository(
        profileRepository: profiles,
        aiService: const MockAiService(),
      );
    });

    tearDown(() {
      matches.dispose();
      profiles.dispose();
    });

    test('взаимный лайк создаёт активный мэтч', () async {
      final Match match = await matches.likeProfile('p_sofia');

      expect(match.status, MatchStatus.active);
      expect(match.compatibility, inInclusiveRange(0, 100));
      expect(match.matchedAt, isNotNull);
    });

    test('повторный лайк не дублирует мэтч', () async {
      await matches.likeProfile('p_sofia');
      final List<Match> all = await matches.getMatches();

      expect(
        all.where((Match m) => m.otherUserId('me') == 'p_sofia'),
        hasLength(1),
      );
    });

    test('watchMatches транслирует изменения', () async {
      final Stream<List<Match>> stream = matches.watchMatches();
      final Future<List<Match>> first = stream.first;
      expect(await first, isNotEmpty);
    });
  });

  group('MockChatRepository', () {
    late MockChatRepository chats;

    setUp(() => chats = MockChatRepository());
    tearDown(() => chats.dispose());

    test('диалоги отсортированы по свежести', () async {
      final List<Conversation> conversations = await chats.getConversations();

      expect(conversations, isNotEmpty);
      expect(conversations.first.id, 'c_anna');
    });

    test('отправка сообщения обновляет диалог', () async {
      final Conversation conversation =
          await chats.getOrCreateConversation('p_anna');
      final int before = (await chats.getMessages(conversation.id)).length;

      final Message sent = await chats.sendMessage(conversation.id, 'привет');

      expect(sent.senderId, 'me');
      expect((await chats.getMessages(conversation.id)).length, before + 1);
      final Conversation updated =
          (await chats.getConversationById(conversation.id))!;
      expect(updated.lastMessage?.id, sent.id);
    });

    test('markAsRead сбрасывает непрочитанные', () async {
      await chats.markAsRead('c_anna');
      final Conversation updated = (await chats.getConversationById('c_anna'))!;

      expect(updated.unreadCount, 0);
      expect(updated.hasUnread, isFalse);
    });
  });

  group('Провайдеры', () {
    test('отдают репозитории и потоки данных', () async {
      final ProviderContainer container = ProviderContainer();
      addTearDown(container.dispose);

      final Profile? me = await container.read(
        profileRepositoryProvider,
      ).getCurrentProfile();
      expect(me?.id, 'me');

      final List<Profile> discovery =
          await container.read(discoveryProfilesProvider.future);
      expect(discovery, isNotEmpty);

      final List<Match> matches =
          await container.read(matchesProvider.future);
      expect(matches, isNotEmpty);

      final List<Conversation> conversations =
          await container.read(conversationsProvider.future);
      expect(conversations, isNotEmpty);
    });
  });
}
