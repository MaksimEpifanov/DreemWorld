import 'package:flutter/material.dart';

import '../../../core/theme/index.dart';
import '../../../core/widgets/index.dart';
import '../../../data/models/index.dart';

/// Карточка кандидата в подборе: фото-заглушка, имя, возраст, город,
/// интересы, процент совместимости и кнопки «Пропустить» / «Нравится».
class UserCard extends StatelessWidget {
  const UserCard({
    super.key,
    required this.profile,
    required this.compatibility,
    this.isBusy = false,
    this.onLike,
    this.onPass,
  });

  final Profile profile;

  /// Процент совместимости (0–100) из [AiService].
  final int compatibility;

  /// Блокирует кнопки во время запроса.
  final bool isBusy;

  final VoidCallback? onLike;
  final VoidCallback? onPass;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color primary = theme.colorScheme.primary;

    return NeonCard(
      color: primary,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _Photo(profile: profile, compatibility: compatibility),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _Title(profile: profile),
                if ((profile.city ?? '').isNotEmpty) ...<Widget>[
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: <Widget>[
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Flexible(
                        child: Text(
                          profile.city!,
                          style: AppTextStyles.caption(),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
                if ((profile.bio ?? '').isNotEmpty) ...<Widget>[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    profile.bio!,
                    style: AppTextStyles.body(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (profile.interests.isNotEmpty) ...<Widget>[
                  const SizedBox(height: AppSpacing.md),
                  _Interests(interests: profile.interests, color: primary),
                ],
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: NeonButton(
                        label: 'Пропустить',
                        icon: Icons.close_rounded,
                        variant: NeonButtonVariant.outlined,
                        color: AppColors.error,
                        onPressed: isBusy ? null : onPass,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: NeonButton(
                        label: 'Нравится',
                        icon: Icons.favorite_rounded,
                        onPressed: isBusy ? null : onLike,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title({required this.profile});

  final Profile profile;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: <Widget>[
        Flexible(
          child: Text(
            profile.name,
            style: AppTextStyles.headline(),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          '${profile.age}',
          style: AppTextStyles.title(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

/// Фото-заглушка с бейджем совместимости.
class _Photo extends StatelessWidget {
  const _Photo({required this.profile, required this.compatibility});

  final Profile profile;
  final int compatibility;

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).colorScheme.primary;
    final Color secondary = Theme.of(context).colorScheme.secondary;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(AppRadius.lg),
      ),
      child: SizedBox(
        height: 260,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    primary.withValues(alpha: 0.45),
                    secondary.withValues(alpha: 0.18),
                    AppColors.surfaceElevated,
                  ],
                ),
              ),
              child: Center(
                child: Text(
                  profile.name.isNotEmpty
                      ? profile.name.substring(0, 1).toUpperCase()
                      : '?',
                  style: AppTextStyles.display(color: AppColors.white),
                ),
              ),
            ),
            Positioned(
              right: AppSpacing.md,
              top: AppSpacing.md,
              child: _CompatibilityBadge(
                compatibility: compatibility,
                color: primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompatibilityBadge extends StatelessWidget {
  const _CompatibilityBadge({required this.compatibility, required this.color});

  final int compatibility;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GlowContainer(
      color: color,
      glowRadius: 12,
      glowOpacity: 0.5,
      borderColor: color,
      background: AppColors.surface.withValues(alpha: 0.8),
      borderRadius: AppRadius.pillAll,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md - 4,
        vertical: AppSpacing.sm - 2,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.auto_awesome, size: 14, color: color),
          const SizedBox(width: AppSpacing.xs),
          Text(
            '$compatibility%',
            style: AppTextStyles.label(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}

class _Interests extends StatelessWidget {
  const _Interests({required this.interests, required this.color});

  final List<Interest> interests;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: <Widget>[
        for (final Interest interest in interests.take(6))
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm + 2,
              vertical: AppSpacing.xs + 2,
            ),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: AppRadius.pillAll,
              border: Border.all(color: color.withValues(alpha: 0.35)),
            ),
            child: Text(
              interest.emoji == null
                  ? interest.name
                  : '${interest.emoji} ${interest.name}',
              style: AppTextStyles.caption(color: AppColors.textPrimary),
            ),
          ),
      ],
    );
  }
}
