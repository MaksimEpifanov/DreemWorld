import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/index.dart';
import '../../../../data/models/planet.dart';

/// Собирает художника тематической сцены по её типу.
///
/// [t] — фаза анимации `0..1`, которой управляет хост-виджет сцены.
CustomPainter scenePainterFor({
  required PlanetScene scene,
  required double t,
  required Color primary,
  required Color secondary,
  required Color accent,
}) {
  switch (scene) {
    case PlanetScene.fishing:
      return _FishingPainter(
        t: t,
        primary: primary,
        secondary: secondary,
        accent: accent,
      );
    case PlanetScene.travel:
      return _TravelPainter(
        t: t,
        primary: primary,
        secondary: secondary,
        accent: accent,
      );
    case PlanetScene.gaming:
      return _GamingPainter(
        t: t,
        primary: primary,
        secondary: secondary,
        accent: accent,
      );
    case PlanetScene.music:
      return _MusicPainter(
        t: t,
        primary: primary,
        secondary: secondary,
        accent: accent,
      );
    case PlanetScene.sports:
      return _SportsPainter(
        t: t,
        primary: primary,
        secondary: secondary,
        accent: accent,
      );
    case PlanetScene.food:
      return _FoodPainter(
        t: t,
        primary: primary,
        secondary: secondary,
        accent: accent,
      );
    case PlanetScene.art:
      return _ArtPainter(
        t: t,
        primary: primary,
        secondary: secondary,
        accent: accent,
      );
    case PlanetScene.space:
      return _SpacePainter(
        t: t,
        primary: primary,
        secondary: secondary,
        accent: accent,
      );
  }
}

/// Базовый цвет фона сцены (совпадает с фоном приложения).
const Color _bg = AppColors.background;

/// Базовый класс тематических художников «внутреннего мира» планеты.
///
/// Отвечает за общий каркас (градиентную подложку, виньетку, утилиты) и
/// делегирует конкретную композицию методу [paintScene]. Все художники
/// рассчитаны на дешёвую отрисовку с умеренным числом примитивов.
abstract class _ScenePainter extends CustomPainter {
  _ScenePainter({
    required this.t,
    required this.primary,
    required this.secondary,
    required this.accent,
  });

  /// Фаза анимации в диапазоне `0..1`.
  final double t;

  final Color primary;
  final Color secondary;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    paintScene(canvas, size);

    // Общая виньетка: приглушает края, чтобы контент читался поверх сцены.
    final Rect rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const RadialGradient(
          radius: 1.05,
          colors: <Color>[Color(0x00000000), Color(0x73000000)],
          stops: <double>[0.55, 1.0],
        ).createShader(rect),
    );
  }

  /// Композиция конкретной планеты.
  void paintScene(Canvas canvas, Size size);

  /// Вертикальный градиент на всю сцену.
  void paintBackdrop(Canvas canvas, Size size, List<Color> colors,
      [List<double>? stops]) {
    final Rect rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
          stops: stops,
        ).createShader(rect),
    );
  }

  /// Мягкое радиальное свечение (без blur — только градиент, дёшево).
  void softGlow(Canvas canvas, Offset center, double radius, Color color,
      double alpha) {
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          colors: <Color>[
            color.withValues(alpha: alpha),
            color.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
  }

  /// Детерминированный «шум» в диапазоне `0..1` по целому индексу.
  double rnd(int i) {
    final double x = math.sin(i * 127.1 + 311.7) * 43758.5453;
    return x - x.floorToDouble();
  }

  Color mix(Color a, Color b, double amount) =>
      Color.lerp(a, b, amount.clamp(0.0, 1.0))!;

  @override
  bool shouldRepaint(covariant _ScenePainter oldDelegate) {
    return oldDelegate.t != t ||
        oldDelegate.primary != primary ||
        oldDelegate.secondary != secondary ||
        oldDelegate.accent != accent;
  }
}

// ---------------------------------------------------------------------------
// Рыбалка: слоистая вода, пузырьки, поплавок и проплывающая рыба.
// ---------------------------------------------------------------------------

class _FishingPainter extends _ScenePainter {
  _FishingPainter({
    required super.t,
    required super.primary,
    required super.secondary,
    required super.accent,
  });

  @override
  void paintScene(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    paintBackdrop(canvas, size, <Color>[
      mix(primary, _bg, 0.45),
      mix(primary, _bg, 0.82),
      _bg,
    ], const <double>[0.0, 0.55, 1.0]);

    final double waterLine = h * 0.6;

    // Луна над водой.
    softGlow(canvas, Offset(w * 0.78, h * 0.16), size.shortestSide * 0.3, accent, 0.2);
    canvas.drawCircle(
      Offset(w * 0.78, h * 0.16),
      22,
      Paint()..color = mix(accent, _bg, 0.2).withValues(alpha: 0.9),
    );

    // Слоистые волны.
    for (int layer = 0; layer < 5; layer++) {
      final double amp = 6 + layer * 3;
      final double yBase = waterLine + (layer + 1) * ((h - waterLine) / 6.5);
      final double phase =
          t * math.pi * 2 * (0.08 + layer * 0.05) * (layer.isEven ? 1 : -1);
      final double freq = 0.012 + layer * 0.004;
      final Path path = Path()..moveTo(0, yBase);
      for (double x = 0; x <= w; x += 10) {
        path.lineTo(x, yBase + math.sin(x * freq + phase) * amp);
      }
      path
        ..lineTo(w, h)
        ..lineTo(0, h)
        ..close();
      canvas.drawPath(
        path,
        Paint()
          ..color = mix(primary, accent, layer / 4).withValues(alpha: 0.1 + layer * 0.03),
      );
    }

    // Пузырьки.
    final Paint bubble = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = accent.withValues(alpha: 0.35);
    for (int i = 0; i < 18; i++) {
      final double speed = 0.4 + rnd(i) * 0.6;
      final double prog = (t * speed + rnd(i * 3)) % 1.0;
      final double y = h - prog * (h - waterLine);
      final double x = w * (0.06 + 0.88 * rnd(i * 7)) + math.sin(y * 0.02 + i) * 6;
      canvas.drawCircle(Offset(x, y), 1.2 + rnd(i * 11) * 2.6, bubble);
    }

    // Поплавок, качается на поверхности.
    final double bobX = w * 0.7;
    final double bobY = waterLine + math.sin(t * math.pi * 2 * 1.6) * 3;
    canvas.drawLine(
      Offset(bobX, bobY - 6),
      Offset(bobX, bobY - 28),
      Paint()
        ..strokeWidth = 1.5
        ..color = accent.withValues(alpha: 0.5),
    );
    canvas.drawCircle(Offset(bobX, bobY - 29), 2.5, Paint()..color = accent.withValues(alpha: 0.8));
    canvas.drawCircle(Offset(bobX, bobY), 6, Paint()..color = mix(accent, Colors.white, 0.5));
    canvas.drawCircle(
      Offset(bobX, bobY),
      6,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = AppColors.error.withValues(alpha: 0.9),
    );

    // Силуэт рыбы, плывёт вдоль берега.
    final double fishX = ((t * 0.14) % 1.3 - 0.15) * w;
    final double fishY = waterLine + (h - waterLine) * 0.4 + math.sin(t * math.pi * 2 * 1.3) * 8;
    final Paint fishPaint = Paint()..color = mix(primary, _bg, 0.15).withValues(alpha: 0.7);
    final Path fish = Path()
      ..addOval(Rect.fromCenter(center: Offset(fishX, fishY), width: 38, height: 17))
      ..moveTo(fishX - 19, fishY)
      ..lineTo(fishX - 31, fishY - 10)
      ..lineTo(fishX - 31, fishY + 10)
      ..close();
    canvas.drawPath(fish, fishPaint);
    canvas.drawCircle(Offset(fishX + 12, fishY - 3), 1.6, Paint()..color = Colors.white.withValues(alpha: 0.75));
  }
}

// ---------------------------------------------------------------------------
// Путешествия: закат, дрейфующие облака, скайлайн и пунктирный маршрут.
// ---------------------------------------------------------------------------

class _TravelPainter extends _ScenePainter {
  _TravelPainter({
    required super.t,
    required super.primary,
    required super.secondary,
    required super.accent,
  });

  @override
  void paintScene(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    paintBackdrop(canvas, size, <Color>[
      mix(accent, _bg, 0.55),
      mix(primary, _bg, 0.35),
      _bg,
    ], const <double>[0.0, 0.55, 1.0]);

    // Солнце садится за горизонт.
    final Offset sun = Offset(w * 0.5, h * 0.62);
    final double sunR = size.shortestSide * 0.13;
    softGlow(canvas, sun, size.shortestSide * 0.42, secondary, 0.25);
    canvas.save();
    canvas.clipRect(Rect.fromLTRB(0, 0, w, sun.dy));
    canvas.drawCircle(
      sun,
      sunR,
      Paint()
        ..shader = RadialGradient(
          colors: <Color>[mix(secondary, Colors.white, 0.15), primary],
        ).createShader(Rect.fromCircle(center: sun, radius: sunR)),
    );
    canvas.restore();

    // Облака дрейфуют.
    for (int i = 0; i < 4; i++) {
      final double speed = 0.02 + rnd(i) * 0.03;
      final double x = ((t * speed + rnd(i * 5)) % 1.3 - 0.15) * w;
      final double y = h * (0.12 + 0.14 * rnd(i * 3));
      _cloud(canvas, Offset(x, y), 30 + rnd(i * 9) * 40, Colors.white.withValues(alpha: 0.07));
    }

    // Скайлайн у нижнего края.
    final double base = h * 0.9;
    final Paint city = Paint()..color = mix(_bg, primary, 0.28).withValues(alpha: 0.92);
    final Paint windows = Paint()..color = accent.withValues(alpha: 0.25);
    double x = -w * 0.02;
    int b = 0;
    while (x < w) {
      final double bw = w * (0.05 + 0.05 * rnd(b * 3 + 1));
      final double bh = h * (0.08 + 0.18 * rnd(b * 7 + 2));
      final Rect r = Rect.fromLTWH(x, base - bh, bw, bh + (h - base));
      canvas.drawRect(r, city);
      for (int win = 0; win < 4; win++) {
        if (rnd(b * 13 + win) < 0.5) continue;
        canvas.drawRect(
          Rect.fromLTWH(
            r.left + bw * (0.15 + 0.35 * (win % 2)),
            r.top + bh * (0.15 + 0.22 * (win ~/ 2)),
            bw * 0.16,
            bh * 0.08,
          ),
          windows,
        );
      }
      x += bw + w * 0.012;
      b++;
    }

    // Достопримечательность-башня.
    final double cx = w * 0.6;
    final double th = h * 0.42;
    final double tw = th * 0.16;
    canvas.drawPath(
      Path()
        ..moveTo(cx - tw, base)
        ..lineTo(cx, base - th)
        ..lineTo(cx + tw, base)
        ..close(),
      city,
    );
    canvas.drawRect(
      Rect.fromLTRB(cx - tw * 0.8, base - th * 0.6, cx + tw * 0.8, base - th * 0.55),
      city,
    );
    canvas.drawLine(
      Offset(cx, base - th),
      Offset(cx, base - th * 1.12),
      Paint()
        ..color = city.color
        ..strokeWidth = 2,
    );

    // Пунктирный маршрут и летящий самолёт.
    final Offset p0 = Offset(-0.05 * w, h * 0.78);
    final Offset p1 = Offset(0.5 * w, h * 0.14);
    final Offset p2 = Offset(1.05 * w, h * 0.5);
    _dashedRoute(canvas, p0, p1, p2);
    _plane(canvas, p0, p1, p2);
  }

  void _cloud(Canvas canvas, Offset o, double s, Color color) {
    final Paint paint = Paint()..color = color;
    canvas.drawOval(Rect.fromCenter(center: o, width: s * 1.7, height: s * 0.7), paint);
    canvas.drawOval(
      Rect.fromCenter(center: o.translate(-s * 0.5, -s * 0.1), width: s, height: s * 0.8),
      paint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: o.translate(s * 0.5, -s * 0.05), width: s * 0.9, height: s * 0.7),
      paint,
    );
  }

  Offset _bezier(Offset p0, Offset p1, Offset p2, double u) {
    final double v = 1 - u;
    return Offset(
      v * v * p0.dx + 2 * v * u * p1.dx + u * u * p2.dx,
      v * v * p0.dy + 2 * v * u * p1.dy + u * u * p2.dy,
    );
  }

  Offset _tangent(Offset p0, Offset p1, Offset p2, double u) {
    final double v = 1 - u;
    return Offset(
      2 * v * (p1.dx - p0.dx) + 2 * u * (p2.dx - p1.dx),
      2 * v * (p1.dy - p0.dy) + 2 * u * (p2.dy - p1.dy),
    );
  }

  void _dashedRoute(Canvas canvas, Offset p0, Offset p1, Offset p2) {
    const int segments = 60;
    final Paint paint = Paint()
      ..color = secondary.withValues(alpha: 0.5)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final int shift = (t * segments).floor();
    Offset prev = _bezier(p0, p1, p2, 0);
    for (int i = 1; i <= segments; i++) {
      final Offset cur = _bezier(p0, p1, p2, i / segments);
      if ((i + shift).isEven) canvas.drawLine(prev, cur, paint);
      prev = cur;
    }
  }

  void _plane(Canvas canvas, Offset p0, Offset p1, Offset p2) {
    final Offset pos = _bezier(p0, p1, p2, t);
    final Offset tan = _tangent(p0, p1, p2, t);
    final double ang = math.atan2(tan.dy, tan.dx);
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.rotate(ang);
    softGlow(canvas, Offset.zero, 22, accent, 0.35);
    canvas.drawPath(
      Path()
        ..moveTo(12, 0)
        ..lineTo(-8, -6)
        ..lineTo(-4, 0)
        ..lineTo(-8, 6)
        ..close(),
      Paint()..color = accent,
    );
    canvas.restore();
  }
}

// ---------------------------------------------------------------------------
// Гейминг: синтвейв-горизонт, перспективная сетка и летящие пиксели.
// ---------------------------------------------------------------------------

class _GamingPainter extends _ScenePainter {
  _GamingPainter({
    required super.t,
    required super.primary,
    required super.secondary,
    required super.accent,
  });

  @override
  void paintScene(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    paintBackdrop(canvas, size, <Color>[
      mix(primary, _bg, 0.4),
      mix(accent, _bg, 0.55),
      _bg,
    ], const <double>[0.0, 0.55, 1.0]);

    final double horizon = h * 0.58;

    // Солнце с горизонтальными полосами.
    final Offset sun = Offset(w * 0.5, horizon);
    final double sr = size.shortestSide * 0.22;
    canvas.save();
    canvas.clipRect(Rect.fromLTRB(0, 0, w, horizon));
    canvas.drawCircle(
      sun,
      sr,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[secondary, accent, primary],
        ).createShader(Rect.fromCircle(center: sun, radius: sr)),
    );
    for (int i = 0; i < 5; i++) {
      final double yy = horizon - sr * 0.12 - i * sr * 0.16;
      canvas.drawRect(
        Rect.fromLTRB(w * 0.5 - sr, yy, w * 0.5 + sr, yy + 3 + i * 1.2),
        Paint()..color = _bg.withValues(alpha: 0.85),
      );
    }
    canvas.restore();

    // Линия горизонта.
    canvas.drawLine(
      Offset(0, horizon),
      Offset(w, horizon),
      Paint()
        ..color = accent.withValues(alpha: 0.8)
        ..strokeWidth = 2,
    );

    // Уходящие вдаль горизонтальные линии сетки.
    final double scroll = t * 2;
    for (int i = 0; i < 20; i++) {
      double u = i / 20 + scroll;
      u -= u.floorToDouble();
      final double y = horizon + (h - horizon) * u * u;
      canvas.drawLine(
        Offset(0, y),
        Offset(w, y),
        Paint()..color = accent.withValues(alpha: (1 - u) * 0.5),
      );
    }

    // Сходящиеся вертикальные линии.
    final Offset vanish = Offset(w * 0.5, horizon);
    for (int vx = -6; vx <= 6; vx++) {
      canvas.drawLine(
        vanish,
        Offset(w * 0.5 + vx * w * 0.14, h),
        Paint()..color = accent.withValues(alpha: 0.18),
      );
    }

    // Летящие пиксели.
    for (int i = 0; i < 12; i++) {
      final double speed = 0.1 + rnd(i) * 0.25;
      final double y = h - ((t * speed + rnd(i * 5)) % 1.0) * h;
      final double x = w * rnd(i * 13);
      final double s = 3 + rnd(i * 17) * 5;
      canvas.drawRect(
        Rect.fromLTWH(x, y, s, s),
        Paint()..color = (i.isEven ? accent : secondary).withValues(alpha: 0.5),
      );
    }
  }
}

// ---------------------------------------------------------------------------
// Музыка: эквалайзер и всплывающие ноты.
// ---------------------------------------------------------------------------

class _MusicPainter extends _ScenePainter {
  _MusicPainter({
    required super.t,
    required super.primary,
    required super.secondary,
    required super.accent,
  });

  @override
  void paintScene(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    paintBackdrop(canvas, size, <Color>[
      mix(primary, _bg, 0.45),
      mix(secondary, _bg, 0.6),
      _bg,
    ], const <double>[0.0, 0.55, 1.0]);

    softGlow(canvas, Offset(w * 0.78, h * 0.22), size.shortestSide * 0.35, accent, 0.2);
    softGlow(canvas, Offset(w * 0.18, h * 0.5), size.shortestSide * 0.35, primary, 0.2);

    // Эквалайзер.
    const int bars = 26;
    final double base = h * 0.82;
    final double gap = w / bars;
    for (int i = 0; i < bars; i++) {
      final double phase = t * math.pi * 2 * (0.6 + rnd(i) * 0.8) + i * 0.6;
      final double amp = 0.5 + 0.5 * math.sin(phase);
      final double bh = h * 0.1 + amp * h * 0.28 * (0.5 + rnd(i * 3));
      final double x = i * gap + gap * 0.2;
      final double bw = gap * 0.6;
      final Rect r = Rect.fromLTWH(x, base - bh, bw, bh);
      final RRect rr = RRect.fromRectAndRadius(r, Radius.circular(bw / 2));
      final Color col = mix(primary, accent, amp);
      canvas.drawRRect(
        rr.inflate(2),
        Paint()..color = col.withValues(alpha: 0.15),
      );
      canvas.drawRRect(
        rr,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[accent, col, primary],
          ).createShader(r),
      );
    }
    canvas.drawLine(
      Offset(0, base),
      Offset(w, base),
      Paint()
        ..color = accent.withValues(alpha: 0.4)
        ..strokeWidth = 1.5,
    );

    // Всплывающие ноты.
    for (int i = 0; i < 7; i++) {
      final double speed = 0.05 + rnd(i) * 0.06;
      final double prog = (t * speed * 6 + rnd(i * 5)) % 1.0;
      final double y = h - prog * h * 0.92;
      final double x = w * (0.1 + 0.8 * rnd(i * 7)) +
          math.sin(t * math.pi * 2 * (0.4 + rnd(i) * 0.5) + i) * 16;
      final double alpha = (1 - prog) * 0.65;
      final double rot = math.sin(t * math.pi * 2 * 0.5 + i) * 0.3;
      _note(canvas, Offset(x, y), 12 + rnd(i * 11) * 9, accent.withValues(alpha: alpha), rot);
    }
  }

  void _note(Canvas canvas, Offset o, double s, Color color, double rot) {
    canvas.save();
    canvas.translate(o.dx, o.dy);
    canvas.rotate(rot);
    final Paint paint = Paint()..color = color;
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: s, height: s * 0.72), paint);
    canvas.drawRect(Rect.fromLTWH(s * 0.3, -s * 2.1, s * 0.14, s * 2.1), paint);
    canvas.drawPath(
      Path()
        ..moveTo(s * 0.44, -s * 2.1)
        ..quadraticBezierTo(s * 1.3, -s * 1.7, s * 0.5, -s * 0.6)
        ..close(),
      paint,
    );
    canvas.restore();
  }
}

// ---------------------------------------------------------------------------
// Спорт: трибуны, разметка поля и летающий мяч.
// ---------------------------------------------------------------------------

class _SportsPainter extends _ScenePainter {
  _SportsPainter({
    required super.t,
    required super.primary,
    required super.secondary,
    required super.accent,
  });

  @override
  void paintScene(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    paintBackdrop(canvas, size, <Color>[
      mix(primary, _bg, 0.55),
      mix(primary, _bg, 0.3),
      _bg,
    ], const <double>[0.0, 0.5, 1.0]);

    // Прожекторы по углам.
    softGlow(canvas, Offset(w * 0.12, h * 0.08), size.shortestSide * 0.28, secondary, 0.18);
    softGlow(canvas, Offset(w * 0.88, h * 0.08), size.shortestSide * 0.28, secondary, 0.18);

    // Трибуны: дуги стадиона.
    final Paint stand = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = secondary.withValues(alpha: 0.15);
    for (int i = 0; i < 3; i++) {
      final double inset = w * (0.05 + i * 0.06);
      canvas.drawArc(
        Rect.fromLTRB(inset, h * (0.16 + i * 0.05), w - inset, h * (0.78 + i * 0.04)),
        math.pi,
        math.pi,
        false,
        stand,
      );
    }

    // «Толпа» — редкие точки.
    for (int i = 0; i < 54; i++) {
      final double x = w * (0.08 + 0.84 * rnd(i * 3 + 1));
      final double y = h * (0.22 + 0.26 * rnd(i * 7 + 2));
      canvas.drawCircle(Offset(x, y), 1.5, Paint()..color = accent.withValues(alpha: 0.2));
    }

    // Поле.
    final Rect field = Rect.fromLTRB(w * 0.06, h * 0.5, w * 0.94, h * 0.92);
    final RRect fieldRr = RRect.fromRectAndRadius(field, const Radius.circular(8));
    canvas.drawRRect(
      fieldRr,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            mix(primary, _bg, 0.45),
            mix(primary, _bg, 0.15),
          ],
        ).createShader(field),
    );

    // Разметка.
    final Paint line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..color = Colors.white.withValues(alpha: 0.22);
    canvas.drawRRect(fieldRr.deflate(4), line);
    final double midY = (field.top + field.bottom) / 2;
    canvas.drawLine(Offset(field.left + 4, midY), Offset(field.right - 4, midY), line);
    canvas.drawCircle(Offset(w / 2, midY), field.height * 0.2, line);
    canvas.drawCircle(Offset(w / 2, midY), 2, Paint()..color = Colors.white.withValues(alpha: 0.3));

    // Летающий мяч.
    final double bx = field.left + (0.5 + 0.5 * math.sin(t * math.pi * 2 * 0.5)) * field.width;
    final double bounce = math.sin(t * math.pi * 2 * 1.5).abs();
    final double by = field.bottom - 16 - bounce * field.height * 0.5;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(bx, field.bottom - 4), width: 22, height: 6),
      Paint()..color = Colors.black.withValues(alpha: 0.35),
    );
    softGlow(canvas, Offset(bx, by), 26, accent, 0.25);
    canvas.drawCircle(Offset(bx, by), 11, Paint()..color = Colors.white);
    final Path pent = Path();
    for (int k = 0; k < 5; k++) {
      final double a = -math.pi / 2 + k * 2 * math.pi / 5;
      final Offset pt = Offset(bx + math.cos(a) * 4, by + math.sin(a) * 4);
      if (k == 0) {
        pent.moveTo(pt.dx, pt.dy);
      } else {
        pent.lineTo(pt.dx, pt.dy);
      }
    }
    pent.close();
    canvas.drawPath(pent, Paint()..color = _bg.withValues(alpha: 0.8));
  }
}

// ---------------------------------------------------------------------------
// Еда: тёплые блики, пар и силуэты блюда с приборами.
// ---------------------------------------------------------------------------

class _FoodPainter extends _ScenePainter {
  _FoodPainter({
    required super.t,
    required super.primary,
    required super.secondary,
    required super.accent,
  });

  @override
  void paintScene(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    paintBackdrop(canvas, size, <Color>[
      mix(primary, _bg, 0.5),
      mix(secondary, _bg, 0.7),
      _bg,
    ], const <double>[0.0, 0.55, 1.0]);

    // Тёплые блики боке.
    for (int i = 0; i < 16; i++) {
      final double speed = 0.05 + rnd(i) * 0.08;
      final double y = h - ((t * speed + rnd(i * 5)) % 1.0) * h;
      final double x = w * rnd(i * 7) + math.sin(t * math.pi * 2 * 0.3 + i) * 10;
      final double r = 8 + rnd(i * 11) * 24;
      softGlow(canvas, Offset(x, y), r, i.isEven ? secondary : accent, 0.16);
    }

    final double cx = w * 0.5;
    final double plateY = h * 0.85;
    final double plateR = size.shortestSide * 0.24;
    final double bowlR = plateR * 0.85;

    // Тарелка.
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, plateY + 8), width: plateR * 2.6, height: plateR * 0.9),
      Paint()..color = mix(_bg, secondary, 0.25).withValues(alpha: 0.6),
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, plateY), width: plateR * 2.2, height: plateR * 0.75),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = secondary.withValues(alpha: 0.4),
    );

    // Пар над блюдом.
    for (int k = 0; k < 3; k++) {
      final double sx = cx + (k - 1) * bowlR * 0.55;
      final double topY = h * 0.18;
      final double baseY = plateY - 24;
      final Path steam = Path()..moveTo(sx, baseY);
      final double wobble = math.sin(t * math.pi * 2 + k) * 12;
      steam.cubicTo(
        sx - 16 + wobble,
        baseY - (baseY - topY) * 0.33,
        sx + 16 - wobble,
        baseY - (baseY - topY) * 0.66,
        sx,
        topY + ((t * 40 + k * 30) % 60),
      );
      canvas.drawPath(
        steam,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round
          ..shader = LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: <Color>[
              accent.withValues(alpha: 0),
              accent.withValues(alpha: 0.42),
              accent.withValues(alpha: 0),
            ],
          ).createShader(Rect.fromLTRB(sx - 20, topY, sx + 20, baseY)),
      );
    }

    // Чаша.
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, plateY - 14), radius: bowlR),
      0,
      math.pi,
      true,
      Paint()..color = mix(primary, _bg, 0.25).withValues(alpha: 0.85),
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, plateY - 14), width: bowlR * 2, height: bowlR * 0.42),
      Paint()..color = mix(secondary, _bg, 0.3).withValues(alpha: 0.9),
    );

    // Приборы.
    _fork(canvas, Offset(cx - plateR * 1.55, plateY), plateR * 1.4, secondary.withValues(alpha: 0.35));
    _spoon(canvas, Offset(cx + plateR * 1.55, plateY), plateR * 1.4, secondary.withValues(alpha: 0.35));
  }

  void _fork(Canvas canvas, Offset o, double len, Color color) {
    canvas.save();
    canvas.translate(o.dx, o.dy);
    final Paint paint = Paint()..color = color;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(0, len * 0.25), width: len * 0.09, height: len * 0.5),
        Radius.circular(len * 0.05),
      ),
      paint,
    );
    for (int i = -1; i <= 1; i++) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(i * len * 0.12, -len * 0.05),
            width: len * 0.06,
            height: len * 0.4,
          ),
          Radius.circular(len * 0.03),
        ),
        paint,
      );
    }
    canvas.restore();
  }

  void _spoon(Canvas canvas, Offset o, double len, Color color) {
    canvas.save();
    canvas.translate(o.dx, o.dy);
    final Paint paint = Paint()..color = color;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(0, len * 0.25), width: len * 0.08, height: len * 0.5),
        Radius.circular(len * 0.04),
      ),
      paint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(0, -len * 0.12), width: len * 0.26, height: len * 0.36),
      paint,
    );
    canvas.restore();
  }
}

// ---------------------------------------------------------------------------
// Творчество: мазки кисти и палитра цветовых пятен.
// ---------------------------------------------------------------------------

class _ArtPainter extends _ScenePainter {
  _ArtPainter({
    required super.t,
    required super.primary,
    required super.secondary,
    required super.accent,
  });

  static const List<Color> _palette = <Color>[
    Color(0xFFD500F9),
    Color(0xFF7C4DFF),
    Color(0xFF00E5FF),
    Color(0xFFFFD166),
    Color(0xFF39FF88),
    Color(0xFFFF4D6D),
  ];

  @override
  void paintScene(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    paintBackdrop(canvas, size, <Color>[
      mix(primary, _bg, 0.5),
      mix(secondary, _bg, 0.62),
      _bg,
    ], const <double>[0.0, 0.55, 1.0]);

    // Мазки кисти.
    for (int i = 0; i < 4; i++) {
      final double y = h * (0.2 + 0.18 * i) + math.sin(t * math.pi * 2 * 0.3 + i) * 10;
      final Color col = _palette[i % _palette.length];
      final Path stroke = Path()..moveTo(w * 0.05, y);
      stroke.cubicTo(
        w * 0.35,
        y - 70 - i * 10 + math.sin(t * math.pi * 2 * (0.2 + i * 0.1)) * 20,
        w * 0.65,
        y + 70 + i * 10,
        w * 0.95,
        y,
      );
      canvas.drawPath(
        stroke,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 16
          ..strokeCap = StrokeCap.round
          ..color = col.withValues(alpha: 0.2),
      );
    }

    // Цветовые пятна палитры, медленно дрейфуют.
    for (int i = 0; i < 8; i++) {
      final double ang = t * math.pi * 2 * (0.03 + rnd(i) * 0.03) + rnd(i * 3) * math.pi * 2;
      final double cx = w * (0.15 + 0.7 * rnd(i * 5)) + math.cos(ang) * w * 0.05;
      final double cy = h * (0.15 + 0.7 * rnd(i * 9)) + math.sin(ang) * h * 0.05;
      final double r = size.shortestSide * (0.08 + 0.16 * rnd(i * 13));
      softGlow(canvas, Offset(cx, cy), r, _palette[i % _palette.length], 0.3);
    }

    // Мелкие брызги.
    for (int i = 0; i < 26; i++) {
      final double x = w * rnd(i * 3 + 1);
      final double y = h * rnd(i * 7 + 2);
      final double r = 2 + rnd(i * 11) * 6;
      canvas.drawCircle(Offset(x, y), r, Paint()..color = _palette[i % _palette.length].withValues(alpha: 0.16));
    }
  }
}

// ---------------------------------------------------------------------------
// Космос: параллакс-звёзды, туманности, планета с кольцами и метеор.
// ---------------------------------------------------------------------------

class _SpacePainter extends _ScenePainter {
  _SpacePainter({
    required super.t,
    required super.primary,
    required super.secondary,
    required super.accent,
  });

  @override
  void paintScene(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    paintBackdrop(canvas, size, <Color>[
      _bg,
      mix(primary, _bg, 0.7),
      _bg,
    ], const <double>[0.0, 0.5, 1.0]);

    // Туманности.
    softGlow(canvas, Offset(w * 0.25, h * 0.3), size.shortestSide * 0.5, accent, 0.16);
    softGlow(canvas, Offset(w * 0.8, h * 0.72), size.shortestSide * 0.45, secondary, 0.12);

    // Параллакс-звёзды с мерцанием.
    const List<int> counts = <int>[46, 30, 18];
    const List<double> speeds = <double>[0.02, 0.05, 0.09];
    for (int layer = 0; layer < 3; layer++) {
      final double sizeBase = 0.6 + layer * 0.7;
      final double drift = (t * speeds[layer]) % 1.0;
      for (int i = 0; i < counts[layer]; i++) {
        final double bx = w * rnd(layer * 100 + i * 3 + 1);
        final double by0 = h * rnd(layer * 100 + i * 7 + 2);
        final double y = (by0 + drift * h) % h;
        final double twinkle = 0.5 + 0.5 * math.sin(t * math.pi * 2 * (0.5 + rnd(i) * 1.5) + i);
        final double alpha = (0.25 + 0.6 * twinkle) * (0.4 + layer * 0.2);
        canvas.drawCircle(
          Offset(bx, y),
          sizeBase * twinkle + 0.3,
          Paint()..color = Colors.white.withValues(alpha: alpha.clamp(0.0, 1.0)),
        );
      }
    }

    // Метеор, проносится периодически.
    final double cycle = (t * 0.5) % 1.0;
    if (cycle < 0.4) {
      final double u = cycle / 0.4;
      final double fade = math.sin(u * math.pi);
      final Offset head = Offset(w * (0.15 + 0.7 * u), h * (0.05 + 0.35 * u));
      final Offset tail = Offset(head.dx - w * 0.14, head.dy - h * 0.1);
      canvas.drawLine(
        tail,
        head,
        Paint()
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round
          ..shader = LinearGradient(
            colors: <Color>[
              accent.withValues(alpha: 0),
              Colors.white.withValues(alpha: 0.85 * fade),
            ],
          ).createShader(Rect.fromPoints(tail, head)),
      );
      canvas.drawCircle(head, 2.6, Paint()..color = Colors.white.withValues(alpha: fade));
    }

    // Планета с кольцами.
    final Offset pc = Offset(w * 0.74, h * 0.3);
    final double pr = size.shortestSide * 0.13;
    final Rect ringRect = Rect.fromCenter(center: Offset.zero, width: pr * 3.4, height: pr * 1.0);

    canvas.save();
    canvas.translate(pc.dx, pc.dy);
    canvas.rotate(-0.42);
    canvas.drawOval(
      ringRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = pr * 0.22
        ..color = secondary.withValues(alpha: 0.35),
    );
    canvas.restore();

    canvas.drawCircle(
      pc,
      pr,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.4, -0.4),
          radius: 1,
          colors: <Color>[
            secondary,
            primary,
            mix(primary, _bg, 0.6),
          ],
          stops: const <double>[0.0, 0.6, 1.0],
        ).createShader(Rect.fromCircle(center: pc, radius: pr)),
    );

    // Передняя половина кольца поверх планеты.
    canvas.save();
    canvas.translate(pc.dx, pc.dy);
    canvas.rotate(-0.42);
    canvas.clipRect(Rect.fromLTRB(-pr * 2.2, 0, pr * 2.2, pr * 1.2));
    canvas.drawOval(
      ringRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = pr * 0.2
        ..color = secondary.withValues(alpha: 0.5),
    );
    canvas.drawOval(
      ringRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = pr * 0.06
        ..color = accent.withValues(alpha: 0.7),
    );
    canvas.restore();
  }
}
