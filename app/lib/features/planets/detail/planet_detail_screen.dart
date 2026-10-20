import 'dart:math' as math;

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
                    onPressed: () => context.go('/discovery'),
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
                        for (int i = 0; i < list.length; i++)
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.sm,
                            ),
                            child: _MemberTile(profile: list[i], index: i),
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

/// Шапка планеты: орбитальный неоновый шар, название и чипы-статистика.
class _PlanetHeader extends StatelessWidget {
  const _PlanetHeader({required this.planet});

  final Planet planet;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const SizedBox(height: AppSpacing.lg),
        _HeroOrb(planet: planet),
        const SizedBox(height: AppSpacing.lg),
        Text(
          planet.name,
          style: AppTextStyles.display(),
          textAlign: TextAlign.center,
        )
            .animate()
            .fadeIn(duration: 500.ms, delay: 100.ms)
            .slideY(
              begin: 0.3,
              end: 0,
              duration: 500.ms,
              delay: 100.ms,
              curve: Curves.easeOutCubic,
            ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          planet.tagline,
          style: AppTextStyles.body(color: planet.accent),
          textAlign: TextAlign.center,
        ).animate().fadeIn(duration: 500.ms, delay: 200.ms),
        const SizedBox(height: AppSpacing.sm),
        Text(
          planet.description,
          style: AppTextStyles.body(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ).animate().fadeIn(duration: 500.ms, delay: 280.ms),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          alignment: WrapAlignment.center,
          children: <Widget>[
            _StatChip(
              icon: Icons.people_alt_outlined,
              label: '${planet.memberCount} участников',
              color: planet.accent,
            ),
            _StatChip(
              icon: Icons.local_fire_department_outlined,
              label: planet.keywords.take(2).join(' · '),
              color: planet.secondary,
              outlined: true,
            ),
          ],
        ).animate().fadeIn(duration: 500.ms, delay: 360.ms),
      ],
    );
  }
}

/// Шар планеты с вращающейся орбитой, свечением и лёгким парением.
class _HeroOrb extends StatelessWidget {
  const _HeroOrb({required this.planet});

  final Planet planet;

  @override
  Widget build(BuildContext context) {
    final Widget orb = Container(
      width: 132,
      height: 132,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(-0.4, -0.4),
          radius: 0.95,
          colors: <Color>[
            planet.secondary,
            planet.primary,
            planet.primary.withValues(alpha: 0.6),
          ],
          stops: const <double>[0.0, 0.62, 1.0],
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: planet.primary.withValues(alpha: 0.65),
            blurRadius: 56,
            spreadRadius: 4,
          ),
          BoxShadow(
            color: planet.secondary.withValues(alpha: 0.32),
            blurRadius: 84,
            spreadRadius: 2,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(planet.emoji, style: const TextStyle(fontSize: 58)),
    )
        .animate(onPlay: (AnimationController controller) => controller.repeat(reverse: true))
        .moveY(begin: -6, end: 6, duration: 2800.ms, curve: Curves.easeInOut);

    return SizedBox(
      width: 190,
      height: 190,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Positioned.fill(
            child: CustomPaint(
              painter: _OrbitPainter(
                color: planet.accent,
                dotColor: planet.secondary,
              ),
            )
                .animate(onPlay: (AnimationController controller) => controller.repeat())
                .rotate(duration: 24000.ms),
          ),
          orb
              .animate()
              .fadeIn(duration: 600.ms)
              .scale(
                begin: const Offset(0.7, 0.7),
                end: const Offset(1, 1),
                duration: 700.ms,
                curve: Curves.easeOutBack,
              ),
        ],
      ),
    );
  }
}

/// Пунктирная орбита с ярким спутником; вращается целиком.
class _OrbitPainter extends CustomPainter {
  const _OrbitPainter({required this.color, required this.dotColor});

  final Color color;
  final Color dotColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    final Rect rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width * 0.96,
      height: size.height * 0.68,
    );
    canvas.drawArc(
      rect,
      0,
      math.pi * 2,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = color.withValues(alpha: 0.28),
    );
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 0.6,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round
        ..color = color.withValues(alpha: 0.85),
    );
    canvas.drawCircle(
      Offset(rect.center.dx, rect.top),
      7,
      Paint()..color = dotColor.withValues(alpha: 0.3),
    );
    canvas.drawCircle(
      Offset(rect.center.dx, rect.top),
      3.4,
      Paint()..color = dotColor,
    );
  }

  @override
  bool shouldRepaint(covariant _OrbitPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.dotColor != dotColor;
  }
}

/// Компактный неоновый чип статистики.
class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.label,
    required this.color,
    this.outlined = false,
  });

  final IconData icon;
  final String label;
  final Color color;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: outlined ? 0.06 : 0.12),
        borderRadius: AppRadius.pillAll,
        border: Border.all(
          color: color.withValues(alpha: outlined ? 0.5 : 0.32),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 15, color: color),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: AppTextStyles.label(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}

class _MemberTile extends ConsumerWidget {
  const _MemberTile({required this.profile, this.index = 0});

  final Profile profile;
  final int index;

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
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: (200 + 60 * index).ms)
        .slideX(
          begin: 0.08,
          end: 0,
          duration: 400.ms,
          delay: (200 + 60 * index).ms,
          curve: Curves.easeOutCubic,
        );
  }
}
