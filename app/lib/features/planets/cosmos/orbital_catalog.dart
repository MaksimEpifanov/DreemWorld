import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/index.dart';
import '../../../../data/models/planet.dart';
import '../../../../core/widgets/cosmic_background.dart';
import 'realistic_planet.dart';
import 'realistic_sun.dart';

/// Орбитальный каталог: солнце в центре и 22 планеты по эллиптическим орбитам.
///
/// Планеты распределены по нескольким наклонённым кольцам, масштабируются
/// по радиусу (ближе к солнцу — крупнее) и равномерно разнесены, чтобы не
/// перекрываться. Карта обёрнута в [InteractiveViewer] — можно приближать.
class OrbitalCatalog extends StatelessWidget {
  const OrbitalCatalog({
    super.key,
    required this.planets,
    required this.onPlanetTap,
    this.showLabels = true,
  });

  final List<Planet> planets;
  final ValueChanged<Planet> onPlanetTap;
  final bool showLabels;

  /// Количество планет на каждом кольце (в сумме — все планеты).
  static List<int> _ringCounts(int total) {
    if (total <= 6) return <int>[total];
    return <int>[4, 6, 6, total - 16];
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width = constraints.maxWidth;
        final double height = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : constraints.maxWidth;
        final double side = width;

        final double canvasWidth = width;
        final double canvasHeight = height;
        final Offset canvasCenter = Offset(canvasWidth / 2, canvasHeight / 2);

        final List<int> rings = _ringCounts(planets.length);
        final int ringCount = rings.length;

        final double sunSize = side * 0.11;
        // Равномерно разносим кольца: заметный отступ от солнца и между
        // орбитами, чтобы планеты не слипались и всё влезало на телефон.
        final double innerRadius = side * 0.26;
        final double outerRadius = side * 0.47;
        final List<double> radii = <double>[
          for (int i = 0; i < ringCount; i++)
            ringCount == 1
                ? side * 0.36
                : innerRadius +
                    (outerRadius - innerRadius) * (i / (ringCount - 1)),
        ];

        int index = 0;
        final List<Widget> children = <Widget>[];

        // По вертикали орбиты заметно вытянуты — так планеты расходятся
        // и не наезжают друг на друга даже на небольшом экране.
        final double ellipse =
            (canvasHeight / canvasWidth).clamp(0.85, 1.35) * 0.72;

        for (int r = 0; r < ringCount; r++) {
          final int count = rings[r];
          final double radius = radii[r];
          final double planetSize =
              sunSize * (0.62 - r * 0.09).clamp(0.32, 0.62);
          final double labelWidth = planetSize * 3.2;

          // Рисуем саму орбиту.
          children.add(
            Positioned(
              left: canvasCenter.dx - radius,
              top: canvasCenter.dy - radius * ellipse,
              width: radius * 2,
              height: radius * 2 * ellipse,
              child: CustomPaint(
                painter: _CatalogOrbitPainter(
                  color: Theme.of(context).colorScheme.primary,
                  emphasis: 1 - r / ringCount,
                ),
              ),
            ),
          );

          final double angleOffset = r * (math.pi / 4);
          for (int i = 0; i < count && index < planets.length; i++, index++) {
            final Planet planet = planets[index];
            final double angle = angleOffset + (2 * math.pi / count) * i;
            final double px = canvasCenter.dx + math.cos(angle) * radius;
            final double py =
                canvasCenter.dy + math.sin(angle) * radius * ellipse;

            children.add(
              Positioned(
                left: px - planetSize / 2,
                top: py - planetSize / 2,
                width: planetSize,
                height: planetSize,
                child: _CatalogPlanet(
                  planet: planet,
                  size: planetSize,
                  lightAlignment: Alignment(
                    -math.cos(angle),
                    -math.sin(angle),
                  ),
                  onTap: () => onPlanetTap(planet),
                )
                    .animate(delay: (index * 40).ms)
                    .fadeIn(duration: 500.ms)
                    .scale(
                      begin: const Offset(0.6, 0.6),
                      end: const Offset(1, 1),
                      curve: Curves.easeOutBack,
                    ),
              ),
            );

            if (showLabels) {
              children.add(
                Positioned(
                  left: px - labelWidth / 2,
                  top: py + planetSize / 2 + 2,
                  width: labelWidth,
                  child: IgnorePointer(
                    child: Center(
                      child: _PlanetLabel(planet: planet),
                    ),
                  ),
                ),
              );
            }
          }
        }

        return CosmicBackground(
          child: Center(
            child: FittedBox(
              fit: BoxFit.contain,
              child: SizedBox(
                width: canvasWidth,
                height: canvasHeight,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: <Widget>[
                    ...children,
                    Positioned(
                      left: canvasCenter.dx - sunSize / 2,
                      top: canvasCenter.dy - sunSize / 2,
                      width: sunSize,
                      height: sunSize,
                      child: RealisticSun(size: sunSize, glow: 0.45),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Подпись под планетой.
class _PlanetLabel extends StatelessWidget {
  const _PlanetLabel({required this.planet});

  final Planet planet;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.black.withValues(alpha: 0.45),
        borderRadius: AppRadius.pillAll,
        border: Border.all(
          color: planet.accent.withValues(alpha: 0.4),
        ),
      ),
      child: Text(
        planet.name.replaceFirst('Планета ', ''),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: AppTextStyles.caption(color: AppColors.textPrimary),
      ),
    );
  }
}

/// Планета-шар с обработчиком нажатия (без подписи — она отдельно).
class _CatalogPlanet extends StatelessWidget {
  const _CatalogPlanet({
    required this.planet,
    required this.size,
    required this.lightAlignment,
    required this.onTap,
  });

  final Planet planet;
  final double size;
  final Alignment lightAlignment;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: RealisticPlanet(
        planet: planet,
        size: size,
        lightAlignment: lightAlignment,
        showRing: _hasRing(planet),
        glow: 0.4,
      ),
    );
  }

  bool _hasRing(Planet planet) {
    switch (planet.scene) {
      case PlanetScene.cinema:
      case PlanetScene.technology:
      case PlanetScene.esoteric:
      case PlanetScene.collecting:
      case PlanetScene.other:
        return true;
      default:
        return false;
    }
  }
}

/// Тонкое наклонённое кольцо орбиты.
class _CatalogOrbitPainter extends CustomPainter {
  _CatalogOrbitPainter({required this.color, required this.emphasis});

  final Color color;
  final double emphasis;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final Rect rect = Rect.fromCenter(
      center: center,
      width: size.width,
      height: size.height,
    );
    canvas.drawOval(
      rect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = color.withValues(alpha: 0.10 + 0.12 * emphasis),
    );
  }

  @override
  bool shouldRepaint(covariant _CatalogOrbitPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.emphasis != emphasis;
}
