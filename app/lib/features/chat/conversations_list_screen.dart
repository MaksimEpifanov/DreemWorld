import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/index.dart';
import '../../core/utils/image_utils.dart';
import '../../core/widgets/index.dart';
import '../../data/models/index.dart';
import '../../data/providers/app_providers.dart';

/// Список диалогов: круглый аватар, имя, последнее сообщение,
/// время и бейдж непрочитанного.
class ConversationsListScreen extends ConsumerWidget {
  const ConversationsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Conversation>> conversationsAsync = ref.watch(
      conversationsProvider,
    );
    final String currentUserId = ref.watch(currentUserIdProvider);
    final Map<String, Profile> profiles = <String, Profile>{
      for (final Profile profile
          in ref.watch(discoveryProfilesProvider).asData?.value ??
              const <Profile>[])
        profile.id: profile,
    };

    return Scaffold(
      appBar: const NeonAppBar(title: 'Чаты'),
      body: SafeArea(
        child: ResponsiveContent(
          child: conversationsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (Object error, StackTrace stackTrace) =>
                const _EmptyChats(
              icon: Icons.error_outline_rounded,
              text: 'Не удалось загрузить чаты',
            ),
            data: (List<Conversation> conversations) {
              if (conversations.isEmpty) {
                return const _EmptyChats(
                  icon: Icons.forum_outlined,
                  text: 'Пока нет чатов',
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
                  return _ConversationTile(
                    conversation: conversation,
                    profile: profiles[otherId],
                    fallbackLetter:
                        otherId.isNotEmpty ? otherId[0].toUpperCase() : '?',
                    index: index,
                    onTap: () => context.push('/chat/${conversation.id}'),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({
    required this.conversation,
    required this.profile,
    required this.fallbackLetter,
    required this.index,
    required this.onTap,
  });

  final Conversation conversation;
  final Profile? profile;
  final String fallbackLetter;
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color primary = scheme.primary;
    final Message? lastMessage = conversation.lastMessage;
    final String name = profile?.name ?? 'Диалог';
    final String subtitle = lastMessage?.displayText ?? 'Нет сообщений';
    final String? time = lastMessage?.createdAt != null
        ? _formatTime(lastMessage!.createdAt!)
        : null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.lgAll,
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.7),
            borderRadius: AppRadius.lgAll,
            border: Border.all(color: primary.withValues(alpha: 0.28)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: primary.withValues(alpha: 0.12),
                blurRadius: 16,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md - 2),
            child: Row(
              children: <Widget>[
                _ConversationAvatar(
                  profile: profile,
                  fallbackLetter: fallbackLetter,
                  color: primary,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              name,
                              style: AppTextStyles.title(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (time != null) ...<Widget>[
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              time,
                              style: AppTextStyles.caption(
                                color: conversation.hasUnread
                                    ? primary
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              subtitle,
                              style: AppTextStyles.body(
                                color: conversation.hasUnread
                                    ? AppColors.textPrimary
                                    : AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (conversation.hasUnread) ...<Widget>[
                            const SizedBox(width: AppSpacing.sm),
                            _UnreadBadge(
                              count: conversation.unreadCount,
                              color: primary,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate(delay: (index * 60).ms)
        .fadeIn(duration: 300.ms)
        .slideX(begin: 0.12, end: 0, curve: Curves.easeOutCubic);
  }

  String _formatTime(DateTime time) {
    final String hour = time.hour.toString().padLeft(2, '0');
    final String minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class _ConversationAvatar extends StatelessWidget {
  const _ConversationAvatar({
    required this.profile,
    required this.fallbackLetter,
    required this.color,
  });

  final Profile? profile;
  final String fallbackLetter;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final Uint8List? bytes = decodeDataUri(profile?.photoUrl);
    final String name = profile?.name ?? '';
    final String letter = name.isNotEmpty
        ? name.substring(0, 1).toUpperCase()
        : fallbackLetter;

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[color, color.withValues(alpha: 0.45)],
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: color.withValues(alpha: 0.45),
            blurRadius: 14,
          ),
        ],
      ),
          child: ClipOval(
        child: bytes != null
            ? Image.memory(bytes, fit: BoxFit.cover)
            : Center(
                child: Text(
                  letter,
                  style: AppTextStyles.title(color: AppColors.white),
                ),
              ),
      ),
    );
  }
}

class _UnreadBadge extends StatelessWidget {
  const _UnreadBadge({required this.count, required this.color});

  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GlowContainer(
      color: color,
      glowRadius: 12,
      glowOpacity: 0.6,
      background: color,
      borderRadius: AppRadius.pillAll,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      child: Text(
        '$count',
        style: AppTextStyles.caption(color: Colors.white).copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _EmptyChats extends StatelessWidget {
  const _EmptyChats({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).colorScheme.primary;
    return Center(
      child: Padding(
        padding: AppSpacing.page,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            GlowContainer(
              color: primary,
              glowRadius: 22,
              glowOpacity: 0.4,
              borderColor: primary,
              background: AppColors.surface,
              borderRadius: AppRadius.pillAll,
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Icon(icon, size: 40, color: primary),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(text, style: AppTextStyles.title(), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
