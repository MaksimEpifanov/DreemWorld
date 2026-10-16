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
        child: ResponsiveContent(
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
      ),
    );
  }

  Widget _content(Profile profile) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Profile? me = ref.watch(currentProfileProvider).valueOrNull;

    return Center(
      child: SingleChildScrollView(
        padding: AppSpacing.page,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _MatchAvatars(me: me, other: profile)
                .animate()
                .fadeIn(duration: 400.ms)
                .scale(
                  begin: const Offset(0.6, 0.6),
                  end: const Offset(1, 1),
                  duration: 900.ms,
                  curve: Curves.elasticOut,
                ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'У вас взаимная симпатия!',
              textAlign: TextAlign.center,
              style: AppTextStyles.display(color: scheme.primary).copyWith(
                shadows: <Shadow>[
                  Shadow(
                    color: scheme.primary.withValues(alpha: 0.9),
                    blurRadius: 18,
                  ),
                  Shadow(
                    color: scheme.tertiary.withValues(alpha: 0.7),
                    blurRadius: 40,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              '${profile.name}, ${profile.age}',
              textAlign: TextAlign.center,
              style: AppTextStyles.headline(),
            ),
            if ((profile.city ?? '').isNotEmpty) ...<Widget>[
              const SizedBox(height: AppSpacing.xs),
              Text(
                profile.city!,
                textAlign: TextAlign.center,
                style: AppTextStyles.caption(),
              ),
            ],
            const SizedBox(height: AppSpacing.xxl),
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
              child: Icon(
                Icons.favorite_border_rounded,
                size: 44,
                color: primary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Мэтч не найден',
              style: AppTextStyles.title(),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            NeonButton(
              label: 'Продолжить поиск',
              icon: Icons.explore_outlined,
              variant: NeonButtonVariant.outlined,
              onPressed: _continueSearch,
            ),
          ],
        ),
      ),
    );
  }
}

/// Перекрывающиеся аватары с пульсирующим сердцем.
class _MatchAvatars extends StatelessWidget {
  const _MatchAvatars({required this.me, required this.other});

  final Profile? me;
  final Profile other;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 168,
      width: 260,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Positioned(
            left: 8,
            child: _Avatar(
              profile: me,
              fallback: 'Т',
              color: scheme.primary,
            ),
          ),
          Positioned(
            right: 8,
            child: _Avatar(
              profile: other,
              fallback: '?',
              color: scheme.secondary,
            ),
          ),
          GlowContainer(
            color: scheme.tertiary,
            glowRadius: 32,
            glowOpacity: 0.75,
            borderColor: scheme.tertiary,
            background: AppColors.surface,
            borderRadius: AppRadius.pillAll,
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Icon(
              Icons.favorite_rounded,
              size: 40,
              color: scheme.tertiary,
            ),
          )
              .animate(onPlay: (AnimationController c) => c.repeat(reverse: true))
              .scaleXY(
                begin: 1,
                end: 1.16,
                duration: 900.ms,
                curve: Curves.easeInOut,
              ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.profile,
    required this.fallback,
    required this.color,
  });

  final Profile? profile;
  final String fallback;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final Uint8List? bytes = decodeDataUri(profile?.photoUrl);
    final String name = profile?.name ?? '';
    final String letter = name.isNotEmpty
        ? name.substring(0, 1).toUpperCase()
        : fallback;

    return Container(
      width: 104,
      height: 104,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[color, color.withValues(alpha: 0.4)],
        ),
        border: Border.all(color: AppColors.white, width: 3),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: color.withValues(alpha: 0.7),
            blurRadius: 24,
          ),
        ],
      ),
      child: ClipOval(
        child: bytes != null
            ? Image.memory(bytes, fit: BoxFit.cover)
            : Center(
                child: Text(
                  letter,
                  style: AppTextStyles.display(color: AppColors.white),
                ),
              ),
      ),
    );
  }
}
