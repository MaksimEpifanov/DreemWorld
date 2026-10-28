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

    return SafeArea(
      child: Column(
        children: <Widget>[
          const _GalaxyHeader(),
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
                        onPressed: () {
                          showDialog<void>(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                backgroundColor: const Color(0xFF0F143C),
                                shape: RoundedRectangleBorder(
                                  borderRadius: AppRadius.lgAll,
                                ),
                                title: const Text('Уведомления'),
                                content: const Text(
                                  'Уведомлений пока нет',
                                  style: TextStyle(color: AppColors.textSecondary),
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    child: const Text('Закрыть'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
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
