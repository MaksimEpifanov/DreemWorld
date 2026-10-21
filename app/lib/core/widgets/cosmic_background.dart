import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Фон глубокого космоса: звёзды, туманности, галактики и Млечный Путь.
///
/// Рисуется процедурно (детерминированно) — без сетевых ресурсов. Фон
/// достаточно яркий и «живой», но с мягкими затемнениями по краям, чтобы
/// интерфейс поверх оставался читаемым.
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
          center: Alignment(-0.1, -0.25),
          radius: 1.35,
          colors: <Color>[
            Color(0xFF2A1E5C),
            Color(0xFF161033),
            Color(0xFF0A0720),
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
    _paintMilkyWay(canvas, size, rnd);
    _paintGalaxies(canvas, size, rnd);
    _paintStars(canvas, size, rnd);
    _paintVignette(canvas, size);
    _paintTint(canvas, size);
  }

  /// Яркие слоистые туманности, задающие глубину и цвет.
  void _paintNebulae(Canvas canvas, Size size, math.Random rnd) {
    const List<Color> blobTints = <Color>[
      Color(0xFF7B3FF2),
      Color(0xFF1E6FD9),
      Color(0xFFD62E7C),
      Color(0xFF17B39B),
      Color(0xFF5A3FD6),
      Color(0xFFE0672E),
    ];
    // Крупные мягкие сгустки.
    for (int i = 0; i < 10; i++) {
      final Offset c = Offset(
        rnd.nextDouble() * size.width,
        rnd.nextDouble() * size.height,
      );
      final double r = size.shortestSide * (0.24 + rnd.nextDouble() * 0.5);
      canvas.drawCircle(
        c,
        r,
        Paint()
          ..color = blobTints[rnd.nextInt(blobTints.length)]
              .withValues(alpha: 0.22)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.5),
      );
    }
    // Яркие светящиеся ядра.
    for (int i = 0; i < 7; i++) {
      final Offset c = Offset(
        rnd.nextDouble() * size.width,
        rnd.nextDouble() * size.height,
      );
      final double r = size.shortestSide * (0.05 + rnd.nextDouble() * 0.12);
      canvas.drawCircle(
        c,
        r,
        Paint()
          ..color = const Color(0xFFD9A8FF).withValues(alpha: 0.18)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.6),
      );
    }
  }

  /// Млечный Путь: светлая туманная полоса с пылевой жилой и звёздами.
  void _paintMilkyWay(Canvas canvas, Size size, math.Random rnd) {
    final double diagonal =
        math.sqrt(size.width * size.width + size.height * size.height);
    final double angle = -0.38;
    final Offset start = Offset(
      size.width * 0.5 - math.cos(angle) * diagonal * 0.62,
      size.height * 0.5 - math.sin(angle) * diagonal * 0.62,
    );
    final Offset end = Offset(
      size.width * 0.5 + math.cos(angle) * diagonal * 0.62,
      size.height * 0.5 + math.sin(angle) * diagonal * 0.62,
    );

    // Слои свечения: от широкого фиолетово-синего к яркому белому ядру.
    final List<List<Object>> layers = <List<Object>>[
      <Object>[size.shortestSide * 0.30, 0.10, const Color(0xFF4A3A8C)],
      <Object>[size.shortestSide * 0.19, 0.14, const Color(0xFF7E6BC4)],
      <Object>[size.shortestSide * 0.10, 0.18, const Color(0xFFB9ACEA)],
      <Object>[size.shortestSide * 0.045, 0.24, const Color(0xFFEDE6FF)],
      <Object>[size.shortestSide * 0.018, 0.30, const Color(0xFFFFFFFF)],
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
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, w * 0.55),
      );
    }

    // Светлые и тёмные облака вдоль полосы.
    for (int i = 0; i < 40; i++) {
      final double t = rnd.nextDouble();
      final Offset p = Offset.lerp(start, end, t)!;
      final double spread = size.shortestSide * 0.06;
      final Offset jitter = Offset(
        (rnd.nextDouble() - 0.5) * spread,
        (rnd.nextDouble() - 0.5) * spread,
      );
      final double r = size.shortestSide * (0.012 + rnd.nextDouble() * 0.04);
      final bool dark = rnd.nextDouble() < 0.32;
      canvas.drawCircle(
        p + jitter,
        r,
        Paint()
          ..color = (dark ? const Color(0xFF0A0612) : const Color(0xFFEDE6FF))
              .withValues(alpha: dark ? 0.30 : 0.16)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 1.2),
      );
    }

    // Тёмная пылевая жила.
    canvas.drawLine(
      start,
      end,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.shortestSide * 0.03
        ..color = const Color(0xFF08040F).withValues(alpha: 0.55)
        ..maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          size.shortestSide * 0.025,
        ),
    );

    // Плотное звёздное скопление вдоль полосы.
    for (int i = 0; i < 320; i++) {
      final double t = rnd.nextDouble();
      final Offset p = Offset.lerp(start, end, t)!;
      final double spread = size.shortestSide * (0.02 + rnd.nextDouble() * 0.085);
      final Offset jitter = Offset(
        (rnd.nextDouble() - 0.5) * spread,
        (rnd.nextDouble() - 0.5) * spread,
      );
      final double r = rnd.nextDouble() * 1.3 + 0.2;
      canvas.drawCircle(
        p + jitter,
        r,
        Paint()
          ..color = Colors.white.withValues(
            alpha: 0.5 + rnd.nextDouble() * 0.5,
          ),
      );
    }
  }

  void _paintGalaxies(Canvas canvas, Size size, math.Random rnd) {
    for (int i = 0; i < 4; i++) {
      final Offset c = Offset(
        rnd.nextDouble() * size.width,
        rnd.nextDouble() * size.height,
      );
      final double r = size.shortestSide * (0.05 + rnd.nextDouble() * 0.1);
      canvas.save();
      canvas.translate(c.dx, c.dy);
      canvas.rotate(rnd.nextDouble() * math.pi);
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: r * 2.6, height: r * 0.8),
        Paint()
          ..color = const Color(0xFFBFA8FF).withValues(alpha: 0.10)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.4),
      );
      canvas.drawCircle(
        Offset.zero,
        r * 0.24,
        Paint()
          ..color = const Color(0xFFFFE9B8).withValues(alpha: 0.28)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.2),
      );
      canvas.restore();
    }
  }

  void _paintStars(Canvas canvas, Size size, math.Random rnd) {
    final int count = (size.width * size.height / 1100).clamp(220, 1500).toInt();
    for (int i = 0; i < count; i++) {
      final Offset p = Offset(
        rnd.nextDouble() * size.width,
        rnd.nextDouble() * size.height,
      );
      final double r = rnd.nextDouble() * 1.6 + 0.3;
      final double alpha = 0.35 + rnd.nextDouble() * 0.65;
      final double hue = rnd.nextDouble();
      final Color color = hue > 0.88
          ? const Color(0xFFBFD8FF)
          : (hue > 0.78 ? const Color(0xFFFFE3BC) : Colors.white);
      canvas.drawCircle(
        p,
        r,
        Paint()..color = color.withValues(alpha: alpha),
      );
    }
    // Яркие звёзды с крестовым ореолом.
    for (int i = 0; i < 9; i++) {
      final Offset p = Offset(
        rnd.nextDouble() * size.width,
        rnd.nextDouble() * size.height,
      );
      final double glow = size.shortestSide * 0.02;
      canvas.drawCircle(
        p,
        glow,
        Paint()
          ..color = const Color(0xFFDCE8FF).withValues(alpha: 0.22)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, glow * 0.9),
      );
      final Paint ray = Paint()
        ..color = Colors.white.withValues(alpha: 0.35)
        ..strokeWidth = 0.9;
      canvas.drawLine(p - Offset(glow, 0), p + Offset(glow, 0), ray);
      canvas.drawLine(p - Offset(0, glow), p + Offset(0, glow), ray);
      canvas.drawCircle(
        p,
        1.7,
        Paint()..color = Colors.white.withValues(alpha: 0.95),
      );
    }
  }

  /// Мягкое затемнение по краям для читаемости интерфейса.
  void _paintVignette(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: Alignment.center,
          radius: 1.05,
          colors: <Color>[
            Colors.transparent,
            const Color(0xFF010008).withValues(alpha: 0.55),
          ],
          stops: const <double>[0.6, 1.0],
        ).createShader(rect),
    );
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
