import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/index.dart';
import '../../../../core/widgets/cosmic_background.dart';
import '../../../../data/models/planet.dart';
import 'realistic_planet.dart';
import 'realistic_sun.dart';

/// Орбитальный каталог: солнце в центре и планеты по эллиптическим орбитам.
///
/// Раскладка считается от РЕАЛЬНЫХ размеров области. Размер планет/солнца
/// берётся от меньшей стороны (чтобы всё влезало по высоте на широком
/// экране ПК), а орбиты растягиваются по ширине. Кольца разнесены, углы
/// чередуются — планеты не наслаиваются.
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
    return <int>[6, 7, total - 13];
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double w = constraints.maxWidth;
        final double h = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : constraints.maxWidth;
        final Offset center = Offset(w / 2, h / 2);

        // Опорный размер — меньшая сторона области (безопасно по высоте).
        final double base = math.min(w, h);

        final List<int> rings = _ringCounts(planets.length);
        final int ringCount = rings.length;

        final double sunSize = (base * 0.26).clamp(64.0, 220.0);
        final double planetMax = sunSize * 0.40;
        final double labelHeight = planetMax * 0.55 + 6;

        // Полуоси орбит: по вертикали — с запасом под планету и подпись,
        // по горизонтали — до края с запасом под планету.
        final double maxRy =
            math.max(30.0, h / 2 - planetMax / 2 - labelHeight - 8);
        final double maxRx =
            math.max(30.0, w / 2 - planetMax / 2 - 16);

        // Кольца разнесены по радиусу так, чтобы соседние не наслаивались.
        final double inner = 0.42;
        final List<double> radiiX = <double>[
          for (int i = 0; i < ringCount; i++)
            ringCount == 1
                ? maxRx * 0.8
                : maxRx * (inner + (1 - inner) * (i / (ringCount - 1))),
        ];

        int index = 0;
        final List<Widget> children = <Widget>[];

        for (int r = 0; r < ringCount; r++) {
          final int count = rings[r];
          final double rx = radiiX[r];
          final double ry = rx * (maxRy / maxRx).clamp(0.35, 1.0);

          // Размер планеты ограничен ещё и шагом по дуге, чтобы планеты
          // одного кольца не смыкались.
          final double arcGap = (2 * math.pi * rx / count) * 0.72;
          final double planetSize = math.min(
            sunSize * (0.40 - r * 0.04),
            math.min(arcGap, planetMax),
          ).clamp(20.0, 40.0);
          final double labelWidth = planetSize * 3.2;

          // Кольцо орбиты.
          children.add(
            Positioned(
              left: center.dx - rx,
              top: center.dy - ry,
              width: rx * 2,
              height: ry * 2,
              child: CustomPaint(
                painter: _CatalogOrbitPainter(
                  color: Theme.of(context).colorScheme.primary,
                  emphasis: 1 - r / ringCount,
                ),
              ),
            ),
          );

          // Углы колец чередуются, чтобы планеты разных орбит не совпадали
          // по направлению и не перекрывались.
          final double angleOffset = r * (math.pi / count);
          for (int i = 0; i < count && index < planets.length; i++, index++) {
            final Planet planet = planets[index];
            final double angle = angleOffset + (2 * math.pi / count) * i;
            final double px = center.dx + math.cos(angle) * rx;
            final double py = center.dy + math.sin(angle) * ry;

            children.add(
              Positioned(
                left: px - planetSize / 2,
                top: py - planetSize / 2,
                width: planetSize,
                height: planetSize,
                child: _CatalogPlanet(
                  planet: planet,
                  size: planetSize,
                  lightAlignment: Alignment(-math.cos(angle), -math.sin(angle)),
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
                    child: Center(child: _PlanetLabel(planet: planet)),
                  ),
                ),
              );
            }
          }
        }

        return CosmicBackground(
          child: Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              ...children,
              Positioned(
                left: center.dx - sunSize / 2,
                top: center.dy - sunSize / 2,
                width: sunSize,
                height: sunSize,
                child: RealisticSun(size: sunSize, glow: 0.45),
              ),
            ],
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
