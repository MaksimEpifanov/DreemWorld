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
          radius: 1.2,
          colors: <Color>[
            Color(0xFF0B0A18),
            Color(0xFF060510),
            Color(0xFF020106),
          ],
          stops: <double>[0.0, 0.55, 1.0],
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
      <Object>[size.shortestSide * 0.16, 0.05, const Color(0xFF6D5AA8)],
      <Object>[size.shortestSide * 0.09, 0.06, const Color(0xFF9C8FD0)],
      <Object>[size.shortestSide * 0.04, 0.07, const Color(0xFFD9D2F2)],
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

    // Плотные «облака» вдоль полосы.
    for (int i = 0; i < 22; i++) {
      final double t = rnd.nextDouble();
      final Offset p = Offset.lerp(start, end, t)!;
      final double spread = size.shortestSide * 0.05;
      final Offset jitter = Offset(
        (rnd.nextDouble() - 0.5) * spread,
        (rnd.nextDouble() - 0.5) * spread,
      );
      final double r = size.shortestSide * (0.01 + rnd.nextDouble() * 0.03);
      canvas.drawCircle(
        p + jitter,
        r,
        Paint()
          ..color = const Color(0xFFDCD3F5).withValues(alpha: 0.10)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 1.2),
      );
    }

    // Тёмная «пылевая» жила вдоль полосы для реалистичности.
    canvas.drawLine(
      start,
      end,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.shortestSide * 0.02
        ..color = const Color(0xFF0A0612).withValues(alpha: 0.35)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, size.shortestSide * 0.02),
    );

    // Плотное звёздное скопление вдоль полосы.
    for (int i = 0; i < 160; i++) {
      final double t = rnd.nextDouble();
      final Offset p = Offset.lerp(start, end, t)!;
      final double spread = size.shortestSide * (0.02 + rnd.nextDouble() * 0.07);
      final Offset jitter = Offset(
        (rnd.nextDouble() - 0.5) * spread,
        (rnd.nextDouble() - 0.5) * spread,
      );
      final double r = rnd.nextDouble() * 1.1 + 0.2;
      canvas.drawCircle(
        p + jitter,
        r,
        Paint()..color = Colors.white.withValues(alpha: 0.5 + rnd.nextDouble() * 0.5),
      );
    }
  }

  void _paintNebulae(Canvas canvas, Size size, math.Random rnd) {
    const List<Color> tints = <Color>[
      Color(0xFF4A1E9E),
      Color(0xFF12457F),
      Color(0xFF7A1C42),
      Color(0xFF125C55),
    ];
    for (int i = 0; i < 5; i++) {
      final Offset c = Offset(
        rnd.nextDouble() * size.width,
        rnd.nextDouble() * size.height,
      );
      final double r = size.shortestSide * (0.25 + rnd.nextDouble() * 0.4);
      canvas.drawCircle(
        c,
        r,
        Paint()
          ..color = tints[rnd.nextInt(tints.length)].withValues(alpha: 0.1)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.5),
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
