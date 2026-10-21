import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Фон глубокого космоса: галактика, туманности, Млечный Путь и звёзды.
///
/// Рисуется процедурно (детерминированно) — без сетевых ресурсов. Основа
/// максимально тёмная, а цвет и глубину дают насыщенные туманности, светящееся
/// ядро галактики и плотные звёздные поля. Мягкое затемнение по краям помогает
/// читаемости интерфейса поверх, но не «глушит» цвет.
class CosmicBackground extends StatelessWidget {
  const CosmicBackground({
    super.key,
    this.seed = 42,
    this.tint,
    this.tintOpacity = 0.12,
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
          center: Alignment(-0.15, -0.35),
          radius: 1.3,
          colors: <Color>[
            Color(0xFF0A0620),
            Color(0xFF04020F),
            Color(0xFF000005),
          ],
          stops: <double>[0.0, 0.5, 1.0],
        ),
      ),
      child: CustomPaint(
        painter: _CosmosPainter(
          seed: seed,
          tint: tint,
          tintOpacity: tintOpacity,
        ),
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

    _paintColorWash(canvas, size);
    _paintNebulae(canvas, size, rnd);
    _paintGalaxy(canvas, size);
    _paintMilkyWay(canvas, size, rnd);
    _paintStars(canvas, size, rnd);
    _paintVignette(canvas, size);
    _paintTint(canvas, size);
  }

  /// Цветовая подложка: широкие насыщенные пятна, задающие богатство палитры.
  void _paintColorWash(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final List<Color> stops = <Color>[
      const Color(0xFF3A1D6E),
      const Color(0xFF1B2E7A),
      const Color(0xFF5A1246),
      const Color(0xFF0A2E4A),
      const Color(0xFF2A0E4A),
    ];
    final List<Alignment> spots = <Alignment>[
      const Alignment(-0.7, -0.6),
      const Alignment(0.8, -0.3),
      const Alignment(-0.4, 0.7),
      const Alignment(0.6, 0.8),
      const Alignment(0.1, 0.0),
    ];
    for (int i = 0; i < stops.length; i++) {
      final Alignment a = spots[i];
      canvas.drawRect(
        rect,
        Paint()
          ..shader = RadialGradient(
            center: a,
            radius: 0.9,
            colors: <Color>[
              stops[i].withValues(alpha: 0.34),
              stops[i].withValues(alpha: 0.0),
            ],
          ).createShader(rect),
      );
    }
  }

  /// Насыщенные туманности с высоким контрастом: тёмный космос, яркие ядра.
  void _paintNebulae(Canvas canvas, Size size, math.Random rnd) {
    // Палитра: фиолетовый, маджента, синий, бирюза, розовый, янтарь.
    const List<Color> tints = <Color>[
      Color(0xFF8A3FF2),
      Color(0xFFDA2E8C),
      Color(0xFF2E6BFF),
      Color(0xFF12C4B8),
      Color(0xFFBE3FD6),
      Color(0xFFF08A2E),
    ];
    // Мягкие газовые облака (умеренные, чтобы не «замыливались»).
    for (int i = 0; i < 10; i++) {
      final Offset c = Offset(
        rnd.nextDouble() * size.width,
        rnd.nextDouble() * size.height,
      );
      final double r = size.shortestSide * (0.16 + rnd.nextDouble() * 0.34);
      canvas.drawCircle(
        c,
        r,
        Paint()
          ..color = tints[rnd.nextInt(tints.length)].withValues(alpha: 0.30)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.42),
      );
    }
    // Яркие компактные ядра ионизированного газа.
    for (int i = 0; i < 12; i++) {
      final Offset c = Offset(
        rnd.nextDouble() * size.width,
        rnd.nextDouble() * size.height,
      );
      final double r = size.shortestSide * (0.014 + rnd.nextDouble() * 0.06);
      canvas.drawCircle(
        c,
        r,
        Paint()
          ..color = const Color(0xFFF4D4FF).withValues(alpha: 0.5)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.7),
      );
    }
  }

  /// Наклонённая спиральная галактика: яркое ядро, диск и рукава.
  void _paintGalaxy(Canvas canvas, Size size) {
    final Offset center = Offset(size.width * 0.74, size.height * 0.30);
    final double radius = size.shortestSide * 0.34;
    final double tilt = -0.42;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(tilt);

    // Внешнее гало диска.
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset.zero,
        width: radius * 2.3,
        height: radius * 0.9,
      ),
      Paint()
        ..color = const Color(0xFF6C7BD6).withValues(alpha: 0.18)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 0.4),
    );
    // Основной диск.
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset.zero,
        width: radius * 1.7,
        height: radius * 0.62,
      ),
      Paint()
        ..color = const Color(0xFFAABBF5).withValues(alpha: 0.24)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 0.28),
    );
    // Пылевая полоса поперёк диска.
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset.zero,
        width: radius * 1.5,
        height: radius * 0.12,
      ),
      Paint()
        ..color = const Color(0xFF1A1030).withValues(alpha: 0.6)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 0.06),
    );
    // Яркое тёплое ядро с ореолом.
    canvas.drawCircle(
      Offset.zero,
      radius * 0.28,
      Paint()
        ..color = const Color(0xFFFFE6A8).withValues(alpha: 0.45)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 0.16),
    );
    canvas.drawCircle(
      Offset.zero,
      radius * 0.09,
      Paint()
        ..color = const Color(0xFFFFF9EC).withValues(alpha: 0.95)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 0.035),
    );
    canvas.restore();
  }

  /// Млечный Путь: широкая туманная полоса с пылевыми жилами и звёздами.
  void _paintMilkyWay(Canvas canvas, Size size, math.Random rnd) {
    final double diagonal =
        math.sqrt(size.width * size.width + size.height * size.height);
    const double angle = 0.42;
    final Offset start = Offset(
      size.width * 0.5 - math.cos(angle) * diagonal * 0.62,
      size.height * 0.5 - math.sin(angle) * diagonal * 0.62,
    );
    final Offset end = Offset(
      size.width * 0.5 + math.cos(angle) * diagonal * 0.62,
      size.height * 0.5 + math.sin(angle) * diagonal * 0.62,
    );

    // Слои свечения: от широкого фиолетово-синего к тёплому белому ядру.
    final List<List<Object>> layers = <List<Object>>[
      <Object>[size.shortestSide * 0.34, 0.10, const Color(0xFF3B2E7A)],
      <Object>[size.shortestSide * 0.22, 0.14, const Color(0xFF6A5AB8)],
      <Object>[size.shortestSide * 0.13, 0.18, const Color(0xFFBCAEF0)],
      <Object>[size.shortestSide * 0.07, 0.24, const Color(0xFFE6DEFA)],
      <Object>[size.shortestSide * 0.028, 0.34, const Color(0xFFFFFFFF)],
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

    // Тёмные пылевые прожилки вдоль полосы (несколько, разной кривизны).
    for (int i = 0; i < 3; i++) {
      final Offset shift = Offset(
        (rnd.nextDouble() - 0.5) * size.shortestSide * 0.08,
        (rnd.nextDouble() - 0.5) * size.shortestSide * 0.08,
      );
      canvas.drawLine(
        start + shift,
        end + shift,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = size.shortestSide * (0.015 + i * 0.012)
          ..color = const Color(0xFF05030C).withValues(alpha: 0.5)
          ..maskFilter = MaskFilter.blur(
            BlurStyle.normal,
            size.shortestSide * 0.02,
          ),
      );
    }

    // Плотное звёздное скопление вдоль полосы.
    for (int i = 0; i < 420; i++) {
      final double t = rnd.nextDouble();
      final Offset p = Offset.lerp(start, end, t)!;
      final double spread =
          size.shortestSide * (0.02 + rnd.nextDouble() * 0.09);
      final Offset jitter = Offset(
        (rnd.nextDouble() - 0.5) * spread,
        (rnd.nextDouble() - 0.5) * spread,
      );
      final double r = rnd.nextDouble() * 1.2 + 0.2;
      canvas.drawCircle(
        p + jitter,
        r,
        Paint()
          ..color = Colors.white.withValues(
            alpha: 0.4 + rnd.nextDouble() * 0.6,
          ),
      );
    }
  }

  void _paintStars(Canvas canvas, Size size, math.Random rnd) {
    final int count = (size.width * size.height / 900).clamp(320, 2200).toInt();
    for (int i = 0; i < count; i++) {
      final Offset p = Offset(
        rnd.nextDouble() * size.width,
        rnd.nextDouble() * size.height,
      );
      final double r = rnd.nextDouble() * 1.5 + 0.25;
      final double alpha = 0.3 + rnd.nextDouble() * 0.7;
      final double hue = rnd.nextDouble();
      final Color color = hue > 0.9
          ? const Color(0xFFAFCBFF)
          : (hue > 0.8 ? const Color(0xFFFFD9AD) : Colors.white);
      canvas.drawCircle(
        p,
        r,
        Paint()..color = color.withValues(alpha: alpha),
      );
    }
    // Яркие звёзды с крестовым ореолом и лучами.
    for (int i = 0; i < 11; i++) {
      final Offset p = Offset(
        rnd.nextDouble() * size.width,
        rnd.nextDouble() * size.height,
      );
      final double glow = size.shortestSide * (0.014 + rnd.nextDouble() * 0.02);
      canvas.drawCircle(
        p,
        glow,
        Paint()
          ..color = const Color(0xFFD8E4FF).withValues(alpha: 0.22)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, glow * 0.9),
      );
      final Paint ray = Paint()
        ..color = Colors.white.withValues(alpha: 0.32)
        ..strokeWidth = 0.9;
      canvas.drawLine(p - Offset(glow, 0), p + Offset(glow, 0), ray);
      canvas.drawLine(p - Offset(0, glow), p + Offset(0, glow), ray);
      canvas.drawCircle(
        p,
        rnd.nextDouble() * 1.2 + 1.4,
        Paint()..color = Colors.white.withValues(alpha: 0.95),
      );
    }
  }

  /// Мягкое затемнение по самому краю — читаемость интерфейса без потери цвета.
  void _paintVignette(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: Alignment.center,
          radius: 1.1,
          colors: <Color>[
            Colors.transparent,
            const Color(0xFF000002).withValues(alpha: 0.42),
          ],
          stops: const <double>[0.66, 1.0],
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
