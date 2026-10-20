import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Фон глубокого космоса: звёзды, туманности и далёкие галактики.
///
/// Тёмная основа, чтобы интерфейс поверх оставался читаемым. Рисуется
/// процедурно (детерминированно) — без сетевых ресурсов.
class CosmicBackground extends StatelessWidget {
  const CosmicBackground({
    super.key,
    this.seed = 42,
    this.tint,
    this.tintOpacity = 0.14,
    this.child,
  });

  final int seed;

  /// Необязательный оттенок текущей темы, добавляемый мягким свечением.
  final Color? tint;
  final double tintOpacity;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -0.2),
          radius: 1.25,
          colors: <Color>[
            Color(0xFF07061A),
            Color(0xFF04030E),
            Color(0xFF010008),
          ],
          stops: <double>[0.0, 0.5, 1.0],
        ),
      ),
      child: CustomPaint(
        painter: _CosmosPainter(seed: seed, tint: tint, tintOpacity: tintOpacity),
        child: child,
      ),
    );
  }
}

class _CosmosPainter extends CustomPainter {
  _CosmosPainter({
    required this.seed,
    required this.tint,
    required this.tintOpacity,
  });

  final int seed;
  final Color? tint;
  final double tintOpacity;

  @override
  void paint(Canvas canvas, Size size) {
    final math.Random rnd = math.Random(seed);

    _paintMilkyWay(canvas, size, rnd);
    _paintNebulae(canvas, size, rnd);
    _paintGalaxies(canvas, size, rnd);
    _paintStars(canvas, size, rnd);
    _paintTint(canvas, size);
  }

  /// Млечный Путь: светлая туманная полоса, пересекающая диагональ фона.
  void _paintMilkyWay(Canvas canvas, Size size, math.Random rnd) {
    final double diagonal =
        math.sqrt(size.width * size.width + size.height * size.height);
    final double angle = -0.35;
    final Offset start = Offset(
      size.width * 0.5 - math.cos(angle) * diagonal * 0.6,
      size.height * 0.5 - math.sin(angle) * diagonal * 0.6,
    );
    final Offset end = Offset(
      size.width * 0.5 + math.cos(angle) * diagonal * 0.6,
      size.height * 0.5 + math.sin(angle) * diagonal * 0.6,
    );

    // Мягкая светящаяся лента — несколько слоёв с размытием.
    final List<List<Object>> layers = <List<Object>>[
      <Object>[size.shortestSide * 0.22, 0.07, const Color(0xFF5B4A9E)],
      <Object>[size.shortestSide * 0.13, 0.09, const Color(0xFF8C7BC8)],
      <Object>[size.shortestSide * 0.06, 0.11, const Color(0xFFB7A9E6)],
      <Object>[size.shortestSide * 0.025, 0.14, const Color(0xFFF0ECFF)],
    ];
    for (final List<Object> layer in layers) {
      final double w = layer[0] as double;
      final double a = layer[1] as double;
      final Color c = layer[2] as Color;
      canvas.drawLine(
        start,
        end,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = w
          ..strokeCap = StrokeCap.round
          ..color = c.withValues(alpha: a)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, w * 0.6),
      );
    }

    // Плотные «облака» вдоль полосы (светлые и тёмные), кант пыли.
    for (int i = 0; i < 30; i++) {
      final double t = rnd.nextDouble();
      final Offset p = Offset.lerp(start, end, t)!;
      final double spread = size.shortestSide * 0.05;
      final Offset jitter = Offset(
        (rnd.nextDouble() - 0.5) * spread,
        (rnd.nextDouble() - 0.5) * spread,
      );
      final double r = size.shortestSide * (0.01 + rnd.nextDouble() * 0.035);
      final bool dark = rnd.nextDouble() < 0.35;
      canvas.drawCircle(
        p + jitter,
        r,
        Paint()
          ..color = (dark
                  ? const Color(0xFF0A0612)
                  : const Color(0xFFE3DBFA))
              .withValues(alpha: dark ? 0.22 : 0.12)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 1.2),
      );
    }

    // Тёмная «пылевая» жила вдоль полосы для реалистичности.
    canvas.drawLine(
      start,
      end,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.shortestSide * 0.025
        ..color = const Color(0xFF08040F).withValues(alpha: 0.5)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, size.shortestSide * 0.022),
    );

    // Плотное звёздное скопление вдоль полосы.
    for (int i = 0; i < 240; i++) {
      final double t = rnd.nextDouble();
      final Offset p = Offset.lerp(start, end, t)!;
      final double spread = size.shortestSide * (0.02 + rnd.nextDouble() * 0.075);
      final Offset jitter = Offset(
        (rnd.nextDouble() - 0.5) * spread,
        (rnd.nextDouble() - 0.5) * spread,
      );
      final double r = rnd.nextDouble() * 1.2 + 0.2;
      canvas.drawCircle(
        p + jitter,
        r,
        Paint()..color = Colors.white.withValues(alpha: 0.5 + rnd.nextDouble() * 0.5),
      );
    }
  }

  void _paintNebulae(Canvas canvas, Size size, math.Random rnd) {
    const List<Color> tints = <Color>[
      Color(0xFF5B23B8),
      Color(0xFF11539B),
      Color(0xFF9B2154),
      Color(0xFF0F6E63),
      Color(0xFF3A2A86),
    ];
    for (int i = 0; i < 9; i++) {
      final Offset c = Offset(
        rnd.nextDouble() * size.width,
        rnd.nextDouble() * size.height,
      );
      final double r = size.shortestSide * (0.22 + rnd.nextDouble() * 0.45);
      canvas.drawCircle(
        c,
        r,
        Paint()
          ..color = tints[rnd.nextInt(tints.length)].withValues(alpha: 0.14)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.55),
      );
    }
    // Несколько мелких ярких «сгустков» туманности.
    for (int i = 0; i < 6; i++) {
      final Offset c = Offset(
        rnd.nextDouble() * size.width,
        rnd.nextDouble() * size.height,
      );
      final double r = size.shortestSide * (0.04 + rnd.nextDouble() * 0.09);
      canvas.drawCircle(
        c,
        r,
        Paint()
          ..color = const Color(0xFFB98CFF).withValues(alpha: 0.10)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.7),
      );
    }
  }

  void _paintGalaxies(Canvas canvas, Size size, math.Random rnd) {
    for (int i = 0; i < 3; i++) {
      final Offset c = Offset(
        rnd.nextDouble() * size.width,
        rnd.nextDouble() * size.height,
      );
      final double r = size.shortestSide * (0.05 + rnd.nextDouble() * 0.09);
      canvas.save();
      canvas.translate(c.dx, c.dy);
      canvas.rotate(rnd.nextDouble() * math.pi);
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: r * 2.4, height: r * 0.8),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.05)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.4),
      );
      canvas.drawCircle(
        Offset.zero,
        r * 0.22,
        Paint()
          ..color = const Color(0xFFFFE9B8).withValues(alpha: 0.16)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.2),
      );
      canvas.restore();
    }
  }

  void _paintStars(Canvas canvas, Size size, math.Random rnd) {
    final int count = (size.width * size.height / 1600).clamp(120, 900).toInt();
    for (int i = 0; i < count; i++) {
      final Offset p = Offset(
        rnd.nextDouble() * size.width,
        rnd.nextDouble() * size.height,
      );
      final double r = rnd.nextDouble() * 1.4 + 0.3;
      final double alpha = 0.25 + rnd.nextDouble() * 0.65;
      final Color color = rnd.nextDouble() > 0.85
          ? const Color(0xFFBFD8FF)
          : Colors.white;
      canvas.drawCircle(
        p,
        r,
        Paint()..color = color.withValues(alpha: alpha),
      );
    }
    // Несколько ярких звёзд с ореолом.
    for (int i = 0; i < 6; i++) {
      final Offset p = Offset(
        rnd.nextDouble() * size.width,
        rnd.nextDouble() * size.height,
      );
      canvas.drawCircle(
        p,
        size.shortestSide * 0.012,
        Paint()
          ..color = const Color(0xFFDCE8FF).withValues(alpha: 0.18)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
      );
      canvas.drawCircle(
        p,
        1.6,
        Paint()..color = Colors.white.withValues(alpha: 0.9),
      );
    }
  }

  void _paintTint(Canvas canvas, Size size) {
    final Color? t = tint;
    if (t == null || tintOpacity <= 0) return;
    final Rect rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, -0.4),
          radius: 1.1,
          colors: <Color>[
            t.withValues(alpha: tintOpacity),
            t.withValues(alpha: 0.0),
          ],
          stops: const <double>[0.0, 1.0],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(covariant _CosmosPainter oldDelegate) =>
      oldDelegate.seed != seed ||
      oldDelegate.tint != tint ||
      oldDelegate.tintOpacity != tintOpacity;
}
