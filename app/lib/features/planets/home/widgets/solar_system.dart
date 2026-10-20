import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/index.dart';
import '../../../../core/widgets/index.dart';
import '../../../../data/models/planet.dart';
import 'planet_orb.dart';

/// Солнечная система главной: солнце в центре и планеты по орбите.
///
/// Планеты расставляются равномерно по кругу, масштабируясь под доступное
/// пространство. Каждая планета — живой [PlanetOrb] с подписью и переходом
/// во «внутренний мир».
class SolarSystem extends StatelessWidget {
  const SolarSystem({
    super.key,
    required this.planets,
    required this.onPlanetTap,
  });

  final List<Planet> planets;
  final ValueChanged<Planet> onPlanetTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double height = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : constraints.maxWidth;
        final double side = math.min(constraints.maxWidth, height);

        final double sunSize = side * 0.22;
        final double orbit = side * 0.30;
        final double orbSize = side * 0.105;
        final double labelWidth = side * 0.34;

        return Center(
          child: SizedBox(
            width: side,
            height: side,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: <Widget>[
                SizedBox(
                  width: orbit * 2,
                  height: orbit * 2,
                  child: CustomPaint(
                    painter: _OrbitPainter(color: scheme.primary),
                  ),
                ),
                _Sun(size: sunSize, color: scheme.primary),
                for (int i = 0; i < planets.length; i++)
                  _orbitPlanet(
                    planets[i],
                    i,
                    planets.length,
                    orbit,
                    orbSize,
                    labelWidth,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _orbitPlanet(
    Planet planet,
    int index,
    int count,
    double orbit,
    double orbSize,
    double labelWidth,
  ) {
    final double angle = -math.pi / 2 + (2 * math.pi / count) * index;
    final Offset offset = Offset(
      math.cos(angle) * orbit,
      math.sin(angle) * orbit,
    );

    return Transform.translate(
      offset: offset,
      child: _OrbitPlanet(
        planet: planet,
        size: orbSize,
        maxLabelWidth: labelWidth,
        onTap: () => onPlanetTap(planet),
      ),
    );
  }
}

/// Планета на орбите: живой шар и подпись.
class _OrbitPlanet extends StatelessWidget {
  const _OrbitPlanet({
    required this.planet,
    required this.size,
    required this.maxLabelWidth,
    required this.onTap,
  });

  final Planet planet;
  final double size;
  final double maxLabelWidth;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedPress(
      onPressed: onTap,
      scaleDown: 0.9,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          PlanetOrb(planet: planet, size: size),
          const SizedBox(height: AppSpacing.xs),
          Container(
            constraints: BoxConstraints(maxWidth: maxLabelWidth),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 3,
            ),
            decoration: BoxDecoration(
              color: AppColors.background.withValues(alpha: 0.55),
              borderRadius: AppRadius.pillAll,
              border: Border.all(
                color: planet.accent.withValues(alpha: 0.45),
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: planet.primary.withValues(alpha: 0.35),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Text(
              planet.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppTextStyles.caption(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

/// Солнце по центру системы.
class _Sun extends StatelessWidget {
  const _Sun({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox(
        width: size * 1.8,
        height: size * 1.8,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Container(
              width: size * 1.8,
              height: size * 1.8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: <Color>[
                    color.withValues(alpha: 0.42),
                    color.withValues(alpha: 0.14),
                    AppColors.transparent,
                  ],
                  stops: const <double>[0.0, 0.45, 1.0],
                ),
              ),
            )
                .animate(
                  onPlay: (AnimationController controller) =>
                      controller.repeat(reverse: true),
                )
                .scale(
                  begin: const Offset(0.92, 0.92),
                  end: const Offset(1.08, 1.08),
                  duration: 2600.ms,
                  curve: Curves.easeInOut,
                ),
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  center: Alignment(-0.35, -0.35),
                  radius: 0.95,
                  colors: <Color>[
                    Color(0xFFFFF6C8),
                    Color(0xFFFFD166),
                    Color(0xFFFF8A3D),
                  ],
                  stops: <double>[0.0, 0.55, 1.0],
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: const Color(0xFFFFC24B).withValues(alpha: 0.75),
                    blurRadius: size * 0.9,
                    spreadRadius: size * 0.05,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.wb_sunny_rounded,
              size: size * 0.46,
              color: AppColors.white.withValues(alpha: 0.9),
            ),
          ],
        ),
      ),
    );
  }
}

/// Тонкие орбитальные окружности вокруг солнца.
class _OrbitPainter extends CustomPainter {
  const _OrbitPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final double radius = size.shortestSide / 2;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = color.withValues(alpha: 0.16),
    );
    canvas.drawCircle(
      center,
      radius * 0.72,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = color.withValues(alpha: 0.1),
    );
  }

  @override
  bool shouldRepaint(covariant _OrbitPainter oldDelegate) =>
      oldDelegate.color != color;
}
