import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/index.dart';
import '../../../core/widgets/index.dart';
import '../../../data/models/planet.dart';
import '../../../data/models/profile.dart';
import '../../../data/providers/app_providers.dart';
import '../../../data/providers/planet_providers.dart';
import 'widgets/planet_scene.dart';

/// «Внутренний мир» планеты: оформление под её увлечение и участники.
class PlanetDetailScreen extends ConsumerWidget {
  const PlanetDetailScreen({super.key, required this.planetId});

  final String planetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Planet? planet = ref.watch(planetByIdProvider(planetId));

    if (planet == null) {
      return Scaffold(
        appBar: NeonAppBar(
          title: 'Планета',
          leading: BackButton(onPressed: () => context.go('/main')),
        ),
        body: const Center(child: Text('Планета не найдена')),
      );
    }

    final AsyncValue<List<Profile>> members = ref.watch(
      planetMembersProvider(planetId),
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: NeonAppBar(
        title: planet.name,
        leading: BackButton(onPressed: () => context.go('/main')),
      ),
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: PlanetSceneBackground(
              scene: planet.scene,
              primary: planet.primary,
              secondary: planet.secondary,
              accent: planet.accent,
            ),
          ),
          SafeArea(
            child: ResponsiveContent(
              child: ListView(
                padding: AppSpacing.page,
                children: <Widget>[
                  _PlanetHeader(planet: planet),
                  const SizedBox(height: AppSpacing.lg),
                  NeonButton(
                    label: 'Присоединиться',
                    icon: Icons.rocket_launch_outlined,
                    expanded: true,
                    color: planet.primary,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Вы присоединились к «${planet.name}»',
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  NeonButton(
                    label: 'Смотреть всех в подборе',
                    icon: Icons.explore_outlined,
                    variant: NeonButtonVariant.outlined,
                    expanded: true,
                    color: planet.secondary,
                    onPressed: () => context.go('/main/discovery'),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text('Участники планеты', style: AppTextStyles.title()),
                  const SizedBox(height: AppSpacing.sm),
                  members.when(
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppSpacing.lg),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    error: (Object error, StackTrace stackTrace) => Text(
                      'Не удалось загрузить участников',
                      style: AppTextStyles.body(color: AppColors.textMuted),
                    ),
                    data: (List<Profile> list) => Column(
                      children: <Widget>[
                        for (final Profile profile in list)
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.sm,
                            ),
                            child: _MemberTile(profile: profile),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanetHeader extends StatelessWidget {
  const _PlanetHeader({required this.planet});

  final Planet planet;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const SizedBox(height: AppSpacing.lg),
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              center: const Alignment(-0.4, -0.4),
              radius: 0.9,
              colors: <Color>[planet.secondary, planet.primary],
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: planet.primary.withValues(alpha: 0.6),
                blurRadius: 48,
                spreadRadius: 2,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(planet.emoji, style: const TextStyle(fontSize: 52)),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(planet.name, style: AppTextStyles.headline()),
        const SizedBox(height: AppSpacing.xs),
        Text(
          planet.tagline,
          style: AppTextStyles.body(color: planet.accent),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          planet.description,
          style: AppTextStyles.body(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _MemberTile extends ConsumerWidget {
  const _MemberTile({required this.profile});

  final Profile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int compatibility =
        ref.watch(compatibilityProvider(profile)).asData?.value ?? 0;

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Row(
        children: <Widget>[
          AuraAvatar(
            photoUrl: profile.photoUrl,
            size: 52,
            fallbackText: profile.name,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(profile.name, style: AppTextStyles.bodyBold()),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  <String>[
                    if (profile.city != null) profile.city!,
                    if (profile.interestNames.isNotEmpty)
                      profile.interestNames.take(2).join(', '),
                  ].join(' • '),
                  style: AppTextStyles.caption(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          CompatibilityRing(
            percent: compatibility / 100,
            size: 48,
            strokeWidth: 5,
          ),
        ],
      ),
    );
  }
}
