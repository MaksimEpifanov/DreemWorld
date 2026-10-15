import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/index.dart';
import '../../../core/widgets/index.dart';
import '../../../data/models/index.dart';
import '../../../data/providers/app_providers.dart';
import '../../../data/services/mock_ai_service.dart';
import '../../../data/services/translation_service.dart';
import 'widgets/message_bubble.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key, required this.conversationId});

  final String conversationId;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final MockAiService _aiService = const MockAiService();
  final Map<String, String> _translations = <String, String>{};
  String? _translatingMessageId;
  bool _showingTopics = false;
  List<String> _suggestedTopics = <String>[];

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final String text = _textController.text.trim();
    if (text.isEmpty) {
      return;
    }
    await ref
        .read(chatRepositoryProvider)
        .sendMessage(widget.conversationId, text);
    _textController.clear();
    _showingTopics = false;
    _suggestedTopics = <String>[];
    _scrollToBottom();
  }

  Future<void> _translateMessage(Message message) async {
    if (_translatingMessageId == message.id) {
      return;
    }
    setState(() => _translatingMessageId = message.id);
    final TranslationService translationService =
        ref.read(translationServiceProvider);
    final String translated = await translationService.translate(
      message.text,
      fromLang: '',
      toLang: translationService.defaultTargetLanguage,
    );
    if (mounted) {
      setState(() {
        _translations[message.id] = translated;
        _translatingMessageId = null;
      });
    }
  }

  Future<void> _suggestTopics() async {
    setState(() {
      _showingTopics = true;
      _suggestedTopics = <String>[];
    });
    final Profile? me = await ref.read(profileRepositoryProvider).getCurrentProfile();
    final Profile? other = await ref.read(profileRepositoryProvider).getProfileById(
          await _getOtherUserId(),
        );
    if (me != null && other != null) {
      final List<String> topics = await _aiService.suggestTopics(me, other);
      if (mounted) {
        setState(() => _suggestedTopics = topics);
      }
    } else if (mounted) {
      setState(() => _suggestedTopics = <String>[]);
    }
  }

  Future<String> _getOtherUserId() async {
    final Conversation? conversation = await ref
        .read(chatRepositoryProvider)
        .getConversationById(widget.conversationId);
    final String currentUserId = ref.read(currentUserIdProvider);
    if (conversation != null) {
      return conversation.otherParticipantId(currentUserId);
    }
    return currentUserId;
  }

  void _useTopic(String topic) {
    _textController.text = topic;
    _showingTopics = false;
    _suggestedTopics = <String>[];
    FocusScope.of(context).nextFocus();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<Message>> messagesAsync =
        ref.watch(messagesProvider(widget.conversationId));
    final String currentUserId = ref.watch(currentUserIdProvider);

    return Scaffold(
      appBar: NeonAppBar(
        title: 'Чат',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: ResponsiveContent(
          child: Column(
          children: <Widget>[
            Expanded(
              child: messagesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (Object error, StackTrace stackTrace) => const Center(
                  child: Text('Не удалось загрузить сообщения'),
                ),
                data: (List<Message> messages) {
                  _scrollToBottom();
                  if (messages.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: AppSpacing.page,
                        child: Text(
                          'Пока нет сообщений. Напишите первое!',

                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    controller: _scrollController,
                    padding: AppSpacing.page,
                    itemCount: messages.length,
                    itemBuilder: (BuildContext context, int index) {
                      final Message message = messages[index];
                      final bool isMine = message.senderId == currentUserId;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          MessageBubble(
                            message: message,
                            isMine: isMine,
                          ),
                          if (!isMine) ...<Widget>[
                            const SizedBox(height: 2),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton(
                                onPressed: _translatingMessageId == message.id
                                    ? null
                                    : () => _translateMessage(message),
                                child: Text(
                                  _translatingMessageId == message.id
                                      ? 'Перевод...'
                                      : 'Перевод',
                                  style: AppTextStyles.caption(),
                                ),
                              ),
                            ),
                            if (_translations[message.id] != null)
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: AppSpacing.xs,
                                  bottom: AppSpacing.xs,
                                ),
                                child: Text(
                                  _translations[message.id]!,
                                  style: AppTextStyles.caption(),
                                ),
                              ),
                          ],
                        ],
                      );
                    },
                  );
                },
              ),
            ),
            if (_showingTopics && _suggestedTopics.isNotEmpty) ...<Widget>[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  border: Border(
                    top: BorderSide(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Подсказки тем',
                      style: AppTextStyles.title(),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: _suggestedTopics
                          .map(
                            (String topic) => ActionChip(
                              label: Text(topic),
                              onPressed: () => _useTopic(topic),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            ],
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: const InputDecoration(
                        hintText: 'Введите сообщение...',
                        border: OutlineInputBorder(),
                      ),
                      minLines: 1,
                      maxLines: 4,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  IconButton(
                    tooltip: 'Подсказки тем',
                    onPressed: _suggestTopics,
                    icon: const Icon(Icons.lightbulb_outline_rounded),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  IconButton(
                    tooltip: 'Отправить',
                    onPressed: _sendMessage,
                    icon: const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}













