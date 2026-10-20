import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Фон глубокого космоса: звёзды, туманности и далёкие галактики.
///
/// Тёмная основа, чтобы интерфейс поверх оставался читаемым. Рисуется
/// процедурно (детерминированно) — без сетевых ресурсов.
class CosmicBackground extends StatelessWidget {
  const CosmicBackground({super.key, this.seed = 42, this.child});

  final int seed;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -0.2),
          radius: 1.2,
          colors: <Color>[
            Color(0xFF141026),
            Color(0xFF0A0816),
            Color(0xFF04030A),
          ],
          stops: <double>[0.0, 0.55, 1.0],
        ),
      ),
      child: CustomPaint(
        painter: _CosmosPainter(seed: seed),
        child: child,
      ),
    );
  }
}

class _CosmosPainter extends CustomPainter {
  _CosmosPainter({required this.seed});

  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    final math.Random rnd = math.Random(seed);

    _paintNebulae(canvas, size, rnd);
    _paintGalaxies(canvas, size, rnd);
    _paintStars(canvas, size, rnd);
  }

  void _paintNebulae(Canvas canvas, Size size, math.Random rnd) {
    const List<Color> tints = <Color>[
      Color(0xFF6A2CC9),
      Color(0xFF1E63B0),
      Color(0xFFB0285A),
      Color(0xFF1B8A7A),
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
          ..color = tints[rnd.nextInt(tints.length)].withValues(alpha: 0.12)
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
          ..color = Colors.white.withValues(alpha: 0.06)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.4),
      );
      canvas.drawCircle(
        Offset.zero,
        r * 0.22,
        Paint()
          ..color = const Color(0xFFFFE9B8).withValues(alpha: 0.18)
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
  }

  @override
  bool shouldRepaint(covariant _CosmosPainter oldDelegate) =>
      oldDelegate.seed != seed;
}
