import 'package:flutter/material.dart';

import '../../../../core/theme/index.dart';
import '../../../../data/models/planet.dart';

/// Тематический фон «внутреннего мира» планеты.
///
/// Рисует градиент планеты и простые сюжетные элементы под её увлечение
/// (вода, достопримечательности, ноты, пиксели и т.д.).
class PlanetSceneBackground extends StatelessWidget {
  const PlanetSceneBackground({
    super.key,
    required this.scene,
    required this.primary,
    required this.secondary,
    required this.accent,
  });

  final PlanetScene scene;
  final Color primary;
  final Color secondary;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: PlanetScenePainter(
        scene: scene,
        primary: primary,
        secondary: secondary,
        accent: accent,
      ),
    );
  }
}

/// Художник тематического фона планеты.
class PlanetScenePainter extends CustomPainter {
  PlanetScenePainter({
    required this.scene,
    required this.primary,
    required this.secondary,
    required this.accent,
  });

  final PlanetScene scene;
  final Color primary;
  final Color secondary;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final Paint bg = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[
          Color.lerp(primary, AppColors.background, 0.35)!,
          AppColors.background,
          Color.lerp(secondary, AppColors.background, 0.55)!,
        ],
      ).createShader(rect);
    canvas.drawRect(rect, bg);

    final Paint glow = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40);

    // Несколько мягких неоновых пятен — общий фон для всех планет.
    glow.color = accent.withValues(alpha: 0.28);
    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.15),
      size.shortestSide * 0.22,
      glow,
    );
    glow.color = primary.withValues(alpha: 0.25);
    canvas.drawCircle(
      Offset(size.width * 0.15, size.height * 0.85),
      size.shortestSide * 0.26,
      glow,
    );

    switch (scene) {
      case PlanetScene.fishing:
        _paintWaves(canvas, size);
      case PlanetScene.travel:
        _paintLandmarks(canvas, size);
      case PlanetScene.space:
        _paintStars(canvas, size);
      case PlanetScene.gaming:
      case PlanetScene.music:
      case PlanetScene.sports:
      case PlanetScene.food:
      case PlanetScene.art:
        _paintBokeh(canvas, size);
    }
  }

  void _paintWaves(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = accent.withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    for (int i = 0; i < 4; i++) {
      final double y = size.height * (0.68 + i * 0.07);
      final Path path = Path()..moveTo(0, y);
      for (double x = 0; x <= size.width; x += 24) {
        path.relativeLineTo(12, i.isEven ? -8 : 8);
        path.relativeLineTo(12, i.isEven ? 8 : -8);
      }
      canvas.drawPath(path, paint);
    }
  }

  void _paintLandmarks(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = accent.withValues(alpha: 0.2);
    // Упрощённые «архитектурные» силуэты у нижнего края.
    final double base = size.height * 0.86;
    for (double x = size.width * 0.08; x < size.width; x += size.width * 0.22) {
      final double h = size.height * 0.12;
      final Path p = Path()
        ..moveTo(x, base)
        ..lineTo(x + size.width * 0.06, base)
        ..lineTo(x + size.width * 0.03, base - h)
        ..close();
      canvas.drawPath(p, paint);
    }
  }

  void _paintStars(Canvas canvas, Size size) {
    final Paint star = Paint()..color = Colors.white.withValues(alpha: 0.5);
    for (int i = 0; i < 60; i++) {
      final double x = (i * 97 % 100) / 100 * size.width;
      final double y = (i * 53 % 100) / 100 * size.height;
      canvas.drawCircle(Offset(x, y), (i % 3) * 0.6 + 0.4, star);
    }
  }

  void _paintBokeh(Canvas canvas, Size size) {
    final Paint dot = Paint()..color = accent.withValues(alpha: 0.16);
    for (int i = 0; i < 14; i++) {
      final double x = (i * 71 % 100) / 100 * size.width;
      final double y = (i * 37 % 100) / 100 * size.height;
      canvas.drawCircle(Offset(x, y), 6 + (i % 4) * 5, dot);
    }
  }

  @override
  bool shouldRepaint(covariant PlanetScenePainter oldDelegate) {
    return oldDelegate.scene != scene ||
        oldDelegate.primary != primary ||
        oldDelegate.secondary != secondary ||
        oldDelegate.accent != accent;
  }
}
