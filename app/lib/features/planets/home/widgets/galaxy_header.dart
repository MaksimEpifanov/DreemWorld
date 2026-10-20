import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/index.dart';
import '../../../../core/widgets/index.dart';
import '../../../../data/models/planet.dart';
import 'planet_format.dart';

/// Неоновый заголовок «галактики»: приветствие, слоган и сводка по планетам.
class GalaxyHeader extends StatelessWidget {
  const GalaxyHeader({super.key, required this.planets});

  final List<Planet> planets;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final int totalMembers = planets.fold<int>(
      0,
      (int sum, Planet planet) => sum + planet.memberCount,
    );
    final int sceneCount = planets.map((Planet planet) => planet.scene).toSet().length;

    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        Positioned(
          left: -60,
          top: -80,
          child: _GlowBlob(color: scheme.primary, size: 260),
        ),
        Positioned(
          right: -50,
          top: -40,
          child: _GlowBlob(color: scheme.tertiary, size: 200),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _Eyebrow(color: scheme.secondary),
              const SizedBox(height: AppSpacing.sm),
              NeonGradientText(
                'Выбери свою планету',
                gradient: LinearGradient(
                  colors: <Color>[
                    scheme.primary,
                    scheme.secondary,
                    scheme.tertiary,
                  ],
                ),
                style: AppTextStyles.display(),
                glowColor: scheme.primary,
              ),
              const SizedBox(height: AppSpacing.sm + 2),
              Text(
                'Планеты объединяют людей по интересам. Заходи и находи своих.',
                style: AppTextStyles.body(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: <Widget>[
                  _StatChip(
                    icon: Icons.public_rounded,
                    value: '${planets.length}',
                    label: 'планет',
                    color: scheme.primary,
                  ),
                  _StatChip(
                    icon: Icons.people_alt_rounded,
                    value: formatMemberCount(totalMembers),
                    label: 'участников',
                    color: scheme.tertiary,
                  ),
                  _StatChip(
                    icon: Icons.auto_awesome_rounded,
                    value: '$sceneCount',
                    label: 'тем',
                    color: scheme.secondary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    )
        .animate()
        .fadeIn(duration: 420.ms)
        .slideY(
          begin: 0.12,
          end: 0,
          duration: 520.ms,
          curve: Curves.easeOutCubic,
        );
  }
}

/// Надзаголовок с пульсирующей точкой.
class _Eyebrow extends StatelessWidget {
  const _Eyebrow({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: color.withValues(alpha: 0.9),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
        )
            .animate(
              onPlay: (AnimationController controller) =>
                  controller.repeat(reverse: true),
            )
            .fade(begin: 0.4, end: 1, duration: 1600.ms),
        const SizedBox(width: AppSpacing.sm),
        Text(
          'ГАЛАКТИКА ИНТЕРЕСОВ',
          style: AppTextStyles.label(color: color).copyWith(letterSpacing: 2.4),
        ),
      ],
    );
  }
}

/// Размытое неоновое пятно для фона заголовка.
class _GlowBlob extends StatelessWidget {
  const _GlowBlob({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: <Color>[
              color.withValues(alpha: 0.25),
              color.withValues(alpha: 0.08),
              AppColors.transparent,
            ],
            stops: const <double>[0.0, 0.4, 1.0],
          ),
        ),
      ),
    );
  }
}

/// Компактная плашка статистики: иконка, значение и подпись.
class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppRadius.pillAll,
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 16, color: color),
          const SizedBox(width: AppSpacing.sm),
          Text(value, style: AppTextStyles.title()),
          const SizedBox(width: AppSpacing.xs),
          Text(label, style: AppTextStyles.caption()),
        ],
      ),
    );
  }
}
