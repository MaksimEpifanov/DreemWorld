import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
// unused animate import removed

import '../../../core/theme/index.dart';
import '../../../core/widgets/index.dart';
import '../../../data/models/planet.dart';
import '../../../data/models/profile.dart';
import '../../../data/providers/app_providers.dart';
import '../../../data/providers/planet_providers.dart';
import 'widgets/galactic_home_system.dart';

/// Главный экран в стиле «галактика» по референсу DreemWorld.
class PlanetHomeScreen extends ConsumerWidget {
  const PlanetHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<Planet> planets = ref.watch(planetsProvider);

    return Scaffold(
      backgroundColor: AppColors.transparent,
      body: Stack(
        children: <Widget>[
          const Positioned.fill(child: CosmicBackground()),
          SafeArea(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final bool isNarrow = constraints.maxWidth < 900;
                return Column(
                  children: <Widget>[
                    const _GalaxyHeader(),
                    Expanded(
                      child: Stack(
                        children: <Widget>[
                    Expanded(
                      child: GalacticHomeSystem(
                        planets: planets,
                        onPlanetTap: (Planet planet) => context.go(
                          '/main/planet/${planet.id}',
                        ),
                      ),
                    ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _GalaxyHeader extends ConsumerWidget {
  const _GalaxyHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Profile? profile = ref.watch(currentProfileProvider).valueOrNull;
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.sm),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final bool compact = constraints.maxWidth < 1100;
          return Row(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: <Color>[
                          scheme.primary.withValues(alpha: 0.9),
                          scheme.primary.withValues(alpha: 0.4),
                        ],
                      ),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: scheme.primary.withValues(alpha: 0.6),
                          blurRadius: 16,
                          spreadRadius: 1,
                        ),
                      ],
                      border: Border.all(color: scheme.primary.withValues(alpha: 0.8)),
                    ),
                    child: const Icon(Icons.public, color: AppColors.white, size: 20),
                  ),
                  if (!compact) ...<Widget>[
                    const SizedBox(width: AppSpacing.sm),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        NeonGradientText(
                          'DreemWorld',
                          gradient: LinearGradient(colors: <Color>[scheme.primary, scheme.secondary]),
                          style: AppTextStyles.title(),
                          glowColor: scheme.primary,
                        ),
                        Text('Галактика возможностей', style: AppTextStyles.caption(color: AppColors.textMuted)),
                      ],
                    ),
                  ],
                ],
              ),
              const Spacer(),
              if (!compact)
                Flexible(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F143C).withValues(alpha: 0.85),
                        borderRadius: AppRadius.pillAll,
                        border: Border.all(color: scheme.primary.withValues(alpha: 0.35)),
                        boxShadow: <BoxShadow>[
                          BoxShadow(color: scheme.primary.withValues(alpha: 0.18), blurRadius: 18),
                        ],
                      ),
                      child: Row(
                        children: <Widget>[
                          const Icon(Icons.search_rounded, color: AppColors.textMuted, size: 20),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              'Поиск планет, людей, интересов...',
                              style: AppTextStyles.body(color: AppColors.textMuted),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              const Spacer(),
              Row(
                children: <Widget>[
                  Stack(
                    clipBehavior: Clip.none,
                    children: <Widget>[
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.notifications_none_rounded),
                        color: AppColors.white,
                      ),
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: AppRadius.pillAll,
                            boxShadow: <BoxShadow>[
                              BoxShadow(color: AppColors.error.withValues(alpha: 0.7), blurRadius: 10),
                            ],
                          ),
                          child: Text('3', style: AppTextStyles.caption(color: AppColors.white)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  AnimatedPress(
                    onPressed: () => context.go('/profile'),
                    scaleDown: 0.9,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: <Widget>[
                        AuraAvatar(
                          photoUrl: profile?.photoUrl,
                          size: 40,
                          fallbackText: profile?.name,
                          fallbackIcon: Icons.person_rounded,
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF22D3EE),
                              boxShadow: <BoxShadow>[
                                BoxShadow(color: const Color(0xFF22D3EE).withValues(alpha: 0.8), blurRadius: 8),
                              ],
                              border: Border.all(color: AppColors.black, width: 1.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FindByInterestCard extends StatelessWidget {
  const _FindByInterestCard();

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Container(
      width: 280,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFF0F143C).withValues(alpha: 0.88),
        borderRadius: AppRadius.lgAll,
        border: Border.all(color: scheme.primary.withValues(alpha: 0.4)),
        boxShadow: <BoxShadow>[
          BoxShadow(color: scheme.primary.withValues(alpha: 0.22), blurRadius: 28),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.group_rounded, color: AppColors.white, size: 28),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text('Найди своих по интересам', style: AppTextStyles.bodyBold()),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text('Более 2 000 000 людей уже здесь', style: AppTextStyles.caption(color: AppColors.textMuted)),
          const SizedBox(height: AppSpacing.sm),
          NeonButton(
            label: 'Перейти',
            variant: NeonButtonVariant.filled,
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class _PlanetsCountCard extends StatelessWidget {
  const _PlanetsCountCard();

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Container(
      width: 300,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFF0F143C).withValues(alpha: 0.88),
        borderRadius: AppRadius.lgAll,
        border: Border.all(color: scheme.primary.withValues(alpha: 0.4)),
        boxShadow: <BoxShadow>[
          BoxShadow(color: scheme.primary.withValues(alpha: 0.22), blurRadius: 28),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: <Color>[scheme.primary, scheme.secondary]),
                  boxShadow: <BoxShadow>[
                    BoxShadow(color: scheme.primary.withValues(alpha: 0.6), blurRadius: 16),
                  ],
                ),
                child: const Icon(Icons.auto_awesome, color: AppColors.white, size: 20),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Text('22 планеты — тысячи историй', style: AppTextStyles.bodyBold())),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Выбирай то, что вдохновляет. На каждой планете — люди, события, новости и новые возможности.',
            style: AppTextStyles.caption(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _BottomInfoCard extends StatelessWidget {
  const _BottomInfoCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.hasPlanetDots = false,
    this.hasImage = false,
    this.hasAvatars = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool hasPlanetDots;
  final bool hasImage;
  final bool hasAvatars;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Container(
      width: 220,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: const Color(0xFF0F143C).withValues(alpha: 0.88),
        borderRadius: AppRadius.lgAll,
        border: Border.all(color: scheme.primary.withValues(alpha: 0.35)),
        boxShadow: <BoxShadow>[
          BoxShadow(color: scheme.primary.withValues(alpha: 0.16), blurRadius: 20),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(icon, color: scheme.primary, size: 18),
              const SizedBox(width: AppSpacing.xs),
              Expanded(child: Text(title, style: AppTextStyles.caption(color: AppColors.white))),
              Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 18),
            ],
          ),
          Text(subtitle, style: AppTextStyles.caption(color: AppColors.textMuted)),
          const SizedBox(height: AppSpacing.xs),
          if (hasPlanetDots)
            Row(
              children: <Widget>[
                _Dot(color: scheme.secondary),
                _Dot(color: scheme.primary),
                _Dot(color: const Color(0xFFF59E0B)),
                _Dot(color: const Color(0xFF22D3EE)),
              ],
            )
          else if (hasImage)
            Container(
              height: 34,
              decoration: BoxDecoration(
                borderRadius: AppRadius.mdAll,
                gradient: const LinearGradient(colors: <Color>[Color(0xFF1E3A8A), Color(0xFF312E81)]),
              ),
            )
          else if (hasAvatars)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _AvatarDot(),
                Transform.translate(
                  offset: const Offset(-6, 0),
                  child: _AvatarDot(),
                ),
                Transform.translate(
                  offset: const Offset(-12, 0),
                  child: _AvatarDot(),
                ),
                const SizedBox(width: AppSpacing.xs),
                Text('+..', style: AppTextStyles.caption(color: AppColors.textMuted)),
              ],
            ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color});
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      margin: const EdgeInsets.only(right: 4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.9),
        boxShadow: <BoxShadow>[BoxShadow(color: color.withValues(alpha: 0.6), blurRadius: 10)],
      ),
    );
  }
}

class _AvatarDot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      margin: const EdgeInsets.only(right: 4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF334155),
        border: Border.all(color: const Color(0xFF0F143C), width: 2),
      ),
    );
  }
}

class _HandwrittenText extends StatelessWidget {
  const _HandwrittenText();
  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.08,
      child: Text(
        'Больше, чем просто приложение...',
        style: AppTextStyles.bodyBold().copyWith(
          color: const Color(0xFF93C5FD),
          fontStyle: FontStyle.italic,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
