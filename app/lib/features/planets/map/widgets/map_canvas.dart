import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/index.dart';
import '../../../../data/models/map_spot.dart';
import '../../../../data/models/planet.dart';

/// Стилизованная карта планеты: улицы, парки, река и интерактивные отметки.
class MapCanvas extends StatelessWidget {
  const MapCanvas({
    super.key,
    required this.planet,
    required this.spots,
    required this.selectedId,
    required this.onSpotTap,
  });

  final Planet planet;
  final List<MapSpot> spots;
  final String? selectedId;
  final ValueChanged<MapSpot> onSpotTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double w = constraints.maxWidth;
        final double h = constraints.maxHeight;
        return ClipRRect(
          borderRadius: AppRadius.card,
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                child: CustomPaint(
                  painter: _MapBackgroundPainter(
                    primary: planet.primary,
                    secondary: planet.secondary,
                    accent: planet.accent,
                  ),
                ),
              ),
              for (final MapSpot spot in spots)
                Positioned(
                  left: spot.x * w - 22,
                  top: spot.y * h - 22,
                  child: _MapPin(
                    spot: spot,
                    planet: planet,
                    selected: spot.id == selectedId,
                    onTap: () => onSpotTap(spot),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Метка на карте: пульсирующее свечение и эмодзи-иконка.
class _MapPin extends StatelessWidget {
  const _MapPin({
    required this.spot,
    required this.planet,
    required this.selected,
    required this.onTap,
  });

  final MapSpot spot;
  final Planet planet;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color color = spot.color ?? planet.accent;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: selected ? 48 : 40,
            height: selected ? 48 : 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surface.withValues(alpha: 0.92),
              border: Border.all(color: color, width: selected ? 2.5 : 1.5),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: color.withValues(alpha: selected ? 0.7 : 0.4),
                  blurRadius: selected ? 22 : 12,
                  spreadRadius: selected ? 1 : -2,
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              spot.emoji,
              style: TextStyle(fontSize: selected ? 22 : 18),
            ),
          ),
          const SizedBox(height: 2),
          if (selected)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xs,
                vertical: 1,
              ),
              decoration: BoxDecoration(
                color: AppColors.background.withValues(alpha: 0.85),
                borderRadius: AppRadius.pillAll,
              ),
              child: Text(
                spot.title,
                style: AppTextStyles.label(color: AppColors.textPrimary),
              ),
            ),
        ],
      ),
    );
  }
}

/// Рисует подложку карты: кварталы, парки, реку и сетку улиц.
class _MapBackgroundPainter extends CustomPainter {
  _MapBackgroundPainter({
    required this.primary,
    required this.secondary,
    required this.accent,
  });

  final Color primary;
  final Color secondary;
  final Color accent;

  static const Color _bg = AppColors.background;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    final double w = size.width;
    final double h = size.height;

    // Подложка.
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color.lerp(_bg, primary, 0.18)!,
            _bg,
            Color.lerp(_bg, secondary, 0.14)!,
          ],
        ).createShader(Offset.zero & size),
    );

    // Кварталы — мягкие прямоугольники поверх сетки.
    for (int i = 0; i < 26; i++) {
      final double x = w * _rnd(i * 3 + 1);
      final double y = h * _rnd(i * 7 + 2);
      final double bw = w * (0.06 + 0.1 * _rnd(i * 11 + 3));
      final double bh = h * (0.05 + 0.09 * _rnd(i * 13 + 4));
      final Color block = i.isEven
          ? Color.lerp(_bg, primary, 0.28)!
          : Color.lerp(_bg, secondary, 0.24)!;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, bw, bh),
          const Radius.circular(6),
        ),
        Paint()..color = block.withValues(alpha: 0.5),
      );
    }

    // Парки — зелёные пятна.
    for (int i = 0; i < 4; i++) {
      final Offset c = Offset(w * _rnd(i * 19 + 5), h * _rnd(i * 23 + 6));
      final double r = size.shortestSide * (0.08 + 0.06 * _rnd(i * 29));
      canvas.drawCircle(
        c,
        r,
        Paint()
          ..shader = RadialGradient(
            colors: <Color>[
              accent.withValues(alpha: 0.22),
              accent.withValues(alpha: 0),
            ],
          ).createShader(Rect.fromCircle(center: c, radius: r)),
      );
    }

    // Река — широкая извилистая полоса.
    final Path river = Path()..moveTo(-10, h * 0.72);
    river.cubicTo(
      w * 0.3,
      h * 0.55,
      w * 0.6,
      h * 0.9,
      w + 10,
      h * 0.62,
    );
    canvas.drawPath(
      river,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.shortestSide * 0.06
        ..strokeCap = StrokeCap.round
        ..color = Color.lerp(_bg, secondary, 0.5)!.withValues(alpha: 0.55),
    );

    // Сетка улиц.
    final Paint road = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..strokeWidth = 1.4;
    for (double x = 0; x <= w; x += w / 7) {
      canvas.drawLine(Offset(x, 0), Offset(x, h), road);
    }
    for (double y = 0; y <= h; y += h / 9) {
      canvas.drawLine(Offset(0, y), Offset(w, y), road);
    }

    // Пара «магистралей» поярче.
    final Paint highway = Paint()
      ..color = accent.withValues(alpha: 0.18)
      ..strokeWidth = 2.4;
    canvas.drawLine(Offset(0, h * 0.35), Offset(w, h * 0.42), highway);
    canvas.drawLine(Offset(w * 0.28, 0), Offset(w * 0.34, h), highway);

    // Виньетка по краям.
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = const RadialGradient(
          radius: 1.1,
          colors: <Color>[Color(0x00000000), Color(0x61000000)],
          stops: <double>[0.6, 1.0],
        ).createShader(Offset.zero & size),
    );
  }

  static double _rnd(int i) {
    final double x = math.sin(i * 91.7 + 47.3) * 24634.6345;
    return x - x.floorToDouble();
  }

  @override
  bool shouldRepaint(covariant _MapBackgroundPainter oldDelegate) {
    return oldDelegate.primary != primary ||
        oldDelegate.secondary != secondary ||
        oldDelegate.accent != accent;
  }
}
