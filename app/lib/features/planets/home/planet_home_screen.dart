import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/index.dart';
import '../../../core/widgets/index.dart';
import '../../../data/models/planet.dart';
import '../../../data/models/profile.dart';
import '../../../data/providers/app_providers.dart';
import '../../../data/providers/planet_providers.dart';
import 'widgets/solar_system.dart';

/// Главный экран: солнце в центре и планеты-сообщества по орбите.
///
/// Показываются 4 избранные планеты (по интересам профиля, иначе первые 4).
/// Сверху слева — профиль, сверху справа — сияющие уведомления и меню.
class PlanetHomeScreen extends ConsumerWidget {
  const PlanetHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<Planet> planets = ref.watch(featuredPlanetsProvider);

    return Scaffold(
      backgroundColor: AppColors.transparent,
      body: SafeArea(
        child: ResponsiveContent(
          child: Column(
            children: <Widget>[
              const _HomeTopBar(),
              Expanded(
                child: SolarSystem(
                  planets: planets,
                  onPlanetTap: (Planet planet) =>
                      context.go('/main/planet/${planet.id}'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.md,
                  AppSpacing.md,
                ),
                child: NeonButton(
                  label: 'Показать все планеты',
                  icon: Icons.public,
                  variant: NeonButtonVariant.outlined,
                  expanded: true,
                  onPressed: () => context.go('/main/planets'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Верхняя панель: аватар профиля, название, уведомления и меню.
class _HomeTopBar extends ConsumerWidget {
  const _HomeTopBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Profile? profile = ref.watch(currentProfileProvider).valueOrNull;
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.sm,
        0,
      ),
      child: Row(
        children: <Widget>[
          AnimatedPress(
            onPressed: () => context.go('/profile'),
            scaleDown: 0.9,
            child: AuraAvatar(
              photoUrl: profile?.photoUrl,
              size: 44,
              fallbackText: profile?.name,
              fallbackIcon: Icons.person_rounded,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: NeonGradientText(
              'Dreem World',
              gradient: LinearGradient(
                colors: <Color>[scheme.primary, scheme.secondary],
              ),
              style: AppTextStyles.title(),
              glowColor: scheme.primary,
            ),
          ),
          _NotificationStar(onPressed: () => _showNotifications(context)),
          PopupMenuButton<String>(
            tooltip: 'Меню',
            icon: const Icon(Icons.more_horiz_rounded),
            color: AppColors.surface,
            onSelected: (String value) {
              if (value == 'interests') {
                context.go('/main/other-interests');
              } else if (value == 'all') {
                context.go('/main/planets');
              } else if (value == 'settings') {
                context.go('/settings');
              }
            },
            itemBuilder: (BuildContext context) => const <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'interests',
                child: Text('Другие интересы'),
              ),
              PopupMenuItem<String>(
                value: 'all',
                child: Text('Все планеты'),
              ),
              PopupMenuItem<String>(
                value: 'settings',
                child: Text('Настройки'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showNotifications(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: Padding(
            padding: AppSpacing.page,
            child: GlassCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Icon(
                        Icons.auto_awesome_rounded,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text('Уведомления', style: AppTextStyles.title()),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Пока нет новых уведомлений. Здесь появятся сообщения '
                    'о мэтчах, планетам и событиях.',
                    style: AppTextStyles.body(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Сияющая звезда-уведомление с индикатором непрочитанного.
class _NotificationStar extends StatelessWidget {
  const _NotificationStar({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return AnimatedPress(
      onPressed: onPressed,
      scaleDown: 0.88,
      child: SizedBox(
        width: 48,
        height: 48,
        child: Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            Center(
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: <Color>[scheme.primary, scheme.secondary],
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: scheme.primary.withValues(alpha: 0.6),
                      blurRadius: 18,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.white,
                  size: 20,
                ),
              )
                  .animate(
                    onPlay: (AnimationController controller) =>
                        controller.repeat(reverse: true),
                  )
                  .scale(
                    begin: const Offset(0.9, 0.9),
                    end: const Offset(1.06, 1.06),
                    duration: 1500.ms,
                    curve: Curves.easeInOut,
                  ),
            ),
            Positioned(
              right: 6,
              top: 6,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.error,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: AppColors.error.withValues(alpha: 0.8),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
