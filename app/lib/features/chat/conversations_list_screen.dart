import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/index.dart';
import '../../core/widgets/index.dart';
import '../../data/models/index.dart';
import '../../data/providers/app_providers.dart';

class ConversationsListScreen extends ConsumerWidget {
  const ConversationsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Conversation>> conversationsAsync =
        ref.watch(conversationsProvider);
    final String currentUserId = ref.watch(currentUserIdProvider);

    return Scaffold(
      appBar: const NeonAppBar(title: 'Чаты'),
      body: SafeArea(
        child: conversationsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (Object error, StackTrace stackTrace) =>
              const Center(child: Text('Не удалось загрузить чаты')),
          data: (List<Conversation> conversations) {
            if (conversations.isEmpty) {
              return const Center(
                child: Padding(
                  padding: AppSpacing.page,
                  child: Text(
                    'Пока нет чатов',
                    textAlign: TextAlign.center,

                  ),
                ),
              );
            }

            return ListView.separated(
              padding: AppSpacing.page,
              itemCount: conversations.length,
              separatorBuilder: (BuildContext context, int index) =>
                  const SizedBox(height: AppSpacing.sm),
              itemBuilder: (BuildContext context, int index) {
                final Conversation conversation = conversations[index];
                final String otherId =
                    conversation.otherParticipantId(currentUserId);
                final String title = 'Диалог с ';
                final Message? lastMessage = conversation.lastMessage;
                final String subtitle =
                    lastMessage?.displayText ?? 'Нет сообщений';
                final String? time = lastMessage?.createdAt != null
                    ? _formatTime(lastMessage!.createdAt!)
                    : null;

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.mdAll,
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      otherId.isNotEmpty ? otherId[0].toUpperCase() : '?',
                      style: AppTextStyles.title().copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  title: Text(
                    title,
                    style: AppTextStyles.title(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    subtitle,
                    style: AppTextStyles.caption(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      if (time != null)
                        Text(
                          time,
                          style: AppTextStyles.caption(),
                        ),
                      if (conversation.hasUnread) ...<Widget>[
                        const SizedBox(height: 4),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                  onTap: () => context.push('/chat/'),
                );
              },
            );
          },
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final String hour = time.hour.toString().padLeft(2, '0');
    final String minute = time.minute.toString().padLeft(2, '0');
    return hour + ':' + minute;
  }
}






