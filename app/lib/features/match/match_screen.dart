import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/index.dart';
import '../../core/widgets/index.dart';
import '../../data/models/index.dart';
import '../../data/providers/app_providers.dart';

/// Экран «У вас взаимная симпатия!».
///
/// Открывается после взаимного лайка. Позволяет перейти в чат
/// с собеседником или продолжить поиск.
class MatchScreen extends ConsumerStatefulWidget {
  const MatchScreen({super.key, this.userId});

  /// Идентификатор пользователя, с которым совпала симпатия.
  final String? userId;

  @override
  ConsumerState<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends ConsumerState<MatchScreen> {
  late final Future<Profile?> _profileFuture;
  bool _openingChat = false;

  @override
  void initState() {
    super.initState();
    final String? id = widget.userId;
    _profileFuture = id == null
        ? Future<Profile?>.value(null)
        : ref.read(profileRepositoryProvider).getProfileById(id);
  }

  Future<void> _openChat(Profile profile) async {
    if (_openingChat) return;
    setState(() => _openingChat = true);

    final Conversation conversation = await ref
        .read(chatRepositoryProvider)
        .getOrCreateConversation(profile.id);
    if (!mounted) return;

    setState(() => _openingChat = false);
    context.go('/chat/${conversation.id}');
  }

  void _continueSearch() => context.go('/main');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<Profile?>(
          future: _profileFuture,
          builder: (BuildContext context, AsyncSnapshot<Profile?> snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            final Profile? profile = snapshot.data;
            if (profile == null) return _fallback();
            return _content(profile);
          },
        ),
      ),
    );
  }

  Widget _content(Profile profile) {
    final Color primary = Theme.of(context).colorScheme.primary;

    return Center(
      child: SingleChildScrollView(
        padding: AppSpacing.page,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            GlowContainer(
              color: primary,
              glowRadius: 28,
              glowOpacity: 0.55,
              borderColor: primary,
              background: AppColors.surface,
              borderRadius: AppRadius.pillAll,
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Icon(
                Icons.favorite_rounded,
                size: 56,
                color: primary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'У вас взаимная симпатия!',
              style: AppTextStyles.display(color: AppColors.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Вы и ${profile.name} понравились друг другу',
              style: AppTextStyles.body(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            NeonCard(
              color: primary,
              child: Row(
                children: <Widget>[
                  GlowContainer(
                    color: primary,
                    glowRadius: 14,
                    glowOpacity: 0.4,
                    borderColor: primary,
                    background: AppColors.surfaceElevated,
                    borderRadius: AppRadius.pillAll,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Text(
                      profile.name.isNotEmpty
                          ? profile.name.substring(0, 1).toUpperCase()
                          : '?',
                      style: AppTextStyles.headline(color: AppColors.white),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          '${profile.name}, ${profile.age}',
                          style: AppTextStyles.title(),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if ((profile.city ?? '').isNotEmpty) ...<Widget>[
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            profile.city!,
                            style: AppTextStyles.caption(),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            NeonButton(
              label: 'Написать',
              icon: Icons.chat_bubble_outline_rounded,
              isLoading: _openingChat,
              onPressed: _openingChat ? null : () => _openChat(profile),
              expanded: true,
            ),
            const SizedBox(height: AppSpacing.md),
            NeonButton(
              label: 'Продолжить поиск',
              icon: Icons.explore_outlined,
              variant: NeonButtonVariant.outlined,
              onPressed: _openingChat ? null : _continueSearch,
              expanded: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _fallback() {
    return Center(
      child: Padding(
        padding: AppSpacing.page,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.favorite_border_rounded,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Мэтч не найден',
              style: AppTextStyles.title(),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            NeonButton(
              label: 'Продолжить поиск',
              onPressed: _continueSearch,
            ),
          ],
        ),
      ),
    );
  }
}
