import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'planet_art.dart';

/// Фотореалистичное солнце: фактура плазмы и солнечные пятна.
///
/// Строго без лучей, линзовых бликов и гало — только мягкий объёмный свет
/// вокруг диска. Если найден `assets/space/sun.png`, используется он.
class RealisticSun extends StatelessWidget {
  const RealisticSun({super.key, required this.size, this.glow = 0.5});

  /// Диаметр диска солнца.
  final double size;

  /// Сила мягкого объёмного свечения (0 — выключено).
  final double glow;

  @override
  Widget build(BuildContext context) {
    final double canvas = size * (1 + glow);
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
                width: size * (1 + glow * 0.9),
                height: size * (1 + glow * 0.9),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: <Color>[
                      const Color(0xFFFFB347).withValues(alpha: glow * 0.55),
                      const Color(0xFFFF8A3D).withValues(alpha: glow * 0.22),
                      Colors.transparent,
                    ],
                    stops: const <double>[0.0, 0.55, 1.0],
                  ),
                ),
              ),
            Image.asset(
              sunAssetPath,
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
                  painter: const _SunPainter(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SunPainter extends CustomPainter {
  const _SunPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = size.shortestSide / 2;
    final Offset center = size.center(Offset.zero);
    final Rect disc = Rect.fromCircle(center: center, radius: radius);
    final math.Random rnd = math.Random(7);

    canvas.save();
    canvas.clipPath(Path()..addOval(disc));

    // Базовая сфера плазмы.
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.25, -0.3),
          radius: 1.05,
          colors: <Color>[
            Color(0xFFFFFDE7),
            Color(0xFFFFE08A),
            Color(0xFFFFB347),
            Color(0xFFF98A2B),
          ],
          stops: <double>[0.0, 0.32, 0.7, 1.0],
        ).createShader(disc),
    );

    // Грануляция плазмы: множество мягких пятен.
    for (int i = 0; i < 140; i++) {
      final double a = rnd.nextDouble() * math.pi * 2;
      final double d = rnd.nextDouble() * radius * 0.98;
      final Offset p = center + Offset(math.cos(a) * d, math.sin(a) * d);
      final bool hot = rnd.nextBool();
      canvas.drawCircle(
        p,
        radius * (0.03 + rnd.nextDouble() * 0.07),
        Paint()
          ..color = (hot ? const Color(0xFFFFF3C4) : const Color(0xFFE86A1E))
              .withValues(alpha: 0.18)
          ..maskFilter = MaskFilter.blur(
            BlurStyle.normal,
            radius * 0.03,
          ),
      );
    }

    // Солнечные пятна: тёмные ядра с полутенью.
    for (int i = 0; i < 12; i++) {
      final double a = rnd.nextDouble() * math.pi * 2;
      final double d = rnd.nextDouble() * radius * 0.75;
      final Offset p = center + Offset(math.cos(a) * d, math.sin(a) * d);
      final double spot = radius * (0.05 + rnd.nextDouble() * 0.09);
      canvas.drawCircle(
        p,
        spot * 1.6,
        Paint()
          ..color = const Color(0xFFB04A12).withValues(alpha: 0.35)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, spot * 0.4),
      );
      canvas.drawCircle(
        p,
        spot,
        Paint()
          ..color = const Color(0xFF5E2408).withValues(alpha: 0.55)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, spot * 0.25),
      );
    }

    // Мягкое затемнение к краю — объём (лимб).
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          radius: 1.0,
          colors: <Color>[
            Colors.transparent,
            Colors.transparent,
            const Color(0xFF8A3B0A).withValues(alpha: 0.5),
          ],
          stops: const <double>[0.6, 0.82, 1.0],
        ).createShader(disc),
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SunPainter oldDelegate) => false;
}
