import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../data/models/planet.dart';
import 'planet_art.dart';

/// Фотореалистичная (процедурная) планета-шар с тенью от солнца.
///
/// Свет всегда идёт от солнца — задаётся через [lightAlignment] (вектор
/// к центру системы). Если для планеты найден PNG (`assets/planets/<id>.png`),
/// он используется как текстура поверхности; иначе рисуется процедурная
/// поверхность: океаны/материки/кратеры, терминатор, блик и атмосфера.
class RealisticPlanet extends StatelessWidget {
  const RealisticPlanet({
    super.key,
    required this.planet,
    required this.size,
    this.lightAlignment = const Alignment(-0.6, -0.5),
    this.showRing = false,
    this.glow = 0.55,
  });

  final Planet planet;

  /// Диаметр шара.
  final double size;

  /// Направление света (от солнца к планете — со знаком минус).
  final Alignment lightAlignment;

  /// Показывать ли кольца (газовые/металлические планеты).
  final bool showRing;

  /// Сила внешнего свечения (0 — выключено).
  final double glow;

  @override
  Widget build(BuildContext context) {
    final double ringPad = showRing ? size * 0.5 : 0;
    final double canvas = size + ringPad;

    return RepaintBoundary(
      child: SizedBox(
        width: canvas,
        height: canvas,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: <Widget>[
            if (glow > 0)
              Container(
                width: size * 1.35,
                height: size * 1.35,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: <Color>[
                      planet.primary.withValues(alpha: glow * 0.5),
                      planet.secondary.withValues(alpha: glow * 0.18),
                      Colors.transparent,
                    ],
                    stops: const <double>[0.0, 0.5, 1.0],
                  ),
                ),
              ),
            Image.asset(
              planetAssetPath(planet),
              width: size,
              height: size,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
              errorBuilder: (
                BuildContext context,
                Object error,
                StackTrace? stackTrace,
              ) {
                return CustomPaint(
                  size: Size.square(size),
                  painter: _PlanetPainter(
                    planet: planet,
                    lightAlignment: lightAlignment,
                    showRing: showRing,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanetPainter extends CustomPainter {
  _PlanetPainter({
    required this.planet,
    required this.lightAlignment,
    required this.showRing,
  });

  final Planet planet;
  final Alignment lightAlignment;
  final bool showRing;

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = size.shortestSide / 2;
    final Offset center = size.center(Offset.zero);
    final Rect sphere = Rect.fromCircle(center: center, radius: radius);

    final SurfacePalette palette = paletteFor(planet);
    final math.Random rnd = math.Random(planet.id.hashCode);

    if (showRing) _paintRingBack(canvas, center, radius, palette);

    // Слой поверхности, обрезанный по кругу.
    canvas.save();
    canvas.clipPath(Path()..addOval(sphere));

    _paintSurface(canvas, size, radius, palette, rnd);
    _paintLighting(
      canvas,
      size,
      radius,
      palette,
    );
    canvas.restore();

    if (showRing) _paintRingFront(canvas, center, radius, palette);

    _paintAtmosphere(canvas, sphere, palette);
  }

  /// Поверхность: пятна-материки, борозды облаков и мелкая детализация.
  void _paintSurface(
    Canvas canvas,
    Size size,
    double radius,
    SurfacePalette palette,
    math.Random rnd,
  ) {
    final double side = size.shortestSide;
    final Offset center = size.center(Offset.zero);

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.3),
          radius: 1.1,
          colors: <Color>[
            palette.light,
            palette.base,
            palette.dark,
          ],
          stops: const <double>[0.0, 0.55, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );

    // «Материки»: неправильные пятна базового/светлого цвета.
    for (int i = 0; i < 26; i++) {
      final double a = rnd.nextDouble() * math.pi * 2;
      final double d = rnd.nextDouble() * radius * 0.92;
      final Offset p = center + Offset(math.cos(a) * d, math.sin(a) * d * 0.8);
      final double blob = radius * (0.08 + rnd.nextDouble() * 0.22);
      final Color color = rnd.nextBool()
          ? palette.light.withValues(alpha: 0.5)
          : palette.dark.withValues(alpha: 0.45);
      canvas.drawCircle(
        p,
        blob,
        Paint()
          ..color = color
          ..maskFilter = MaskFilter.blur(
            BlurStyle.normal,
            radius * (0.03 + rnd.nextDouble() * 0.05),
          ),
      );
    }

    // Полосы (для газовых/облачных планет) — плавные дуги.
    if (surfaceForScene(planet.scene) == PlanetSurface.gas ||
        surfaceForScene(planet.scene) == PlanetSurface.cloud) {
      for (int i = 0; i < 7; i++) {
        final double y = center.dy - radius + radius * (0.15 + i * 0.12);
        final Paint band = Paint()
          ..color = (i.isEven ? palette.light : palette.dark)
              .withValues(alpha: 0.28)
          ..strokeWidth = radius * (0.05 + rnd.nextDouble() * 0.06)
          ..style = PaintingStyle.stroke;
        final Path path = Path();
        path.moveTo(center.dx - radius, y);
        for (double x = -radius; x <= radius; x += radius / 4) {
          path.quadraticBezierTo(
            center.dx + x,
            y + math.sin((x / radius) * math.pi) * radius * 0.04,
            center.dx + x + radius / 4,
            y,
          );
        }
        canvas.drawPath(path, band);
      }
    }

    // Кратеры/детали — мелкие тёмные точки.
    for (int i = 0; i < 40; i++) {
      final double a = rnd.nextDouble() * math.pi * 2;
      final double d = rnd.nextDouble() * radius * 0.95;
      final Offset p = center + Offset(math.cos(a) * d, math.sin(a) * d);
      canvas.drawCircle(
        p,
        radius * (0.01 + rnd.nextDouble() * 0.03),
        Paint()..color = palette.dark.withValues(alpha: 0.35),
      );
    }

    // Белые полярные шапки у некоторых планет.
    if (surfaceForScene(planet.scene) == PlanetSurface.ice ||
        surfaceForScene(planet.scene) == PlanetSurface.ocean) {
      final Paint cap = Paint()
        ..color = Colors.white.withValues(alpha: 0.5)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 0.06);
      canvas.drawCircle(
        Offset(center.dx, center.dy - radius * 0.85),
        radius * 0.3,
        cap,
      );
      canvas.drawCircle(
        Offset(center.dx, center.dy + radius * 0.85),
        radius * 0.26,
        cap,
      );
    }

    // Игнорируем возможный неиспользуемый параметр side.
    assert(side > 0);
  }

  /// Освещение: блик у источника света и мягкая тень на обратной стороне.
  void _paintLighting(
    Canvas canvas,
    Size size,
    double radius,
    SurfacePalette palette,
  ) {
    final Offset center = size.center(Offset.zero);
    final Rect sphere = Rect.fromCircle(center: center, radius: radius);
    final Offset lightOffset =
        Offset(lightAlignment.x, lightAlignment.y) * radius * 0.9;

    // Терминатор — тёмный градиент со стороны, противоположной свету.
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          center: Alignment(lightAlignment.x, lightAlignment.y),
          radius: 1.25,
          colors: <Color>[
            Colors.transparent,
            Colors.transparent,
            Colors.black.withValues(alpha: 0.72),
          ],
          stops: const <double>[0.35, 0.62, 1.0],
        ).createShader(sphere),
    );

    // Мягкий блик в точке, обращённой к солнцу.
    canvas.drawCircle(
      center + lightOffset,
      radius * 0.32,
      Paint()
        ..shader = RadialGradient(
          colors: <Color>[
            Colors.white.withValues(alpha: 0.55),
            Colors.transparent,
          ],
        ).createShader(
          Rect.fromCircle(center: center + lightOffset, radius: radius * 0.34),
        ),
    );
  }

  /// Задняя часть кольца (за планетой).
  void _paintRingBack(
    Canvas canvas,
    Offset center,
    double radius,
    SurfacePalette palette,
  ) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.transform(
      (Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateX(1.2)
            ..rotateZ(-0.35))
          .storage,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset.zero,
        width: radius * 3.1,
        height: radius * 3.1,
      ),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius * 0.16
        ..color = palette.light.withValues(alpha: 0.32),
    );
    canvas.restore();
  }

  /// Передняя часть кольца (поверх планеты).
  void _paintRingFront(
    Canvas canvas,
    Offset center,
    double radius,
    SurfacePalette palette,
  ) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.clipRect(Rect.fromLTRB(-radius * 2, 0, radius * 2, radius * 2));
    canvas.transform(
      (Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateX(1.2)
            ..rotateZ(-0.35))
          .storage,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset.zero,
        width: radius * 3.1,
        height: radius * 3.1,
      ),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius * 0.16
        ..color = palette.light.withValues(alpha: 0.42),
    );
    canvas.restore();
  }

  /// Тонкая атмосферная кромка вокруг планеты.
  void _paintAtmosphere(Canvas canvas, Rect sphere, SurfacePalette palette) {
    canvas.drawCircle(
      sphere.center,
      sphere.width / 2,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = sphere.width * 0.02
        ..color = palette.light.withValues(alpha: 0.35)
        ..maskFilter = MaskFilter.blur(
          BlurStyle.outer,
          sphere.width * 0.03,
        ),
    );
  }

  @override
  bool shouldRepaint(covariant _PlanetPainter oldDelegate) {
    return oldDelegate.planet != planet ||
        oldDelegate.lightAlignment != lightAlignment ||
        oldDelegate.showRing != showRing;
  }
}
