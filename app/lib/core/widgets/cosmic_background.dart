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

    _paintNebulae(canvas, size, rnd);
    _paintGalaxies(canvas, size, rnd);
    _paintStars(canvas, size, rnd);
    _paintTint(canvas, size);
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
