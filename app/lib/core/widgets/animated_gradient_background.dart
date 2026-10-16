import 'dart:math';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Глобальный слой: анимированный неоновый градиент + затемнение позади [child].
class AnimatedGradientBackgroundLayer extends StatelessWidget {
  const AnimatedGradientBackgroundLayer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        const Positioned.fill(
          child: AnimatedGradientBackground(),
        ),
        Positioned.fill(
          child: Container(
            color: Colors.black.withValues(alpha: 0.28),
          ),
        ),
        child,
      ],
    );
  }
}

/// Полноэкранный анимированный тёмный градиент с плавающими неоновыми кругами.
class AnimatedGradientBackground extends StatefulWidget {
  const AnimatedGradientBackground({super.key, this.palette});

  final NeonPalette? palette;

  @override
  State<AnimatedGradientBackground> createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState
    extends State<AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).disableAnimations) {
      if (_controller.isAnimating) _controller.stop();
      return;
    }
    if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final NeonPalette effective =
        widget.palette ?? Theme.of(context).extension<NeonPaletteExtension>()?.palette ??
            AppPalettes.neonViolet;

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final double t = _controller.value;
          final double ang = pi * 2 * t;
          final Offset center1 = Offset(
            0.3 + 0.2 * sin(ang),
            0.2 + 0.15 * cos(ang),
          );
          final Offset center2 = Offset(
            0.7 + 0.15 * cos(ang + pi / 2),
            0.6 + 0.2 * sin(ang + pi / 2),
          );
          final Offset center3 = Offset(
            0.5 + 0.25 * sin(ang + pi),
            0.4 + 0.25 * cos(ang + pi),
          );

          return DecoratedBox(
            decoration: BoxDecoration(color: effective.background),
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment(-1 + 0.3 * sin(ang), -1 + 0.3 * cos(ang)),
                      end: Alignment(1 - 0.3 * cos(ang), 1 - 0.3 * sin(ang)),
                      colors: <Color>[
                        effective.primary.withValues(alpha: 0.22),
                        effective.secondary.withValues(alpha: 0.16),
                        effective.accent.withValues(alpha: 0.12),
                        effective.background.withValues(alpha: 0.0),
                      ],
                      stops: const <double>[0.0, 0.35, 0.7, 1.0],
                    ),
                  ),
                ),
                CustomPaint(
                  painter: _FloatingOrbsPainter(
                    center1: center1,
                    center2: center2,
                    center3: center3,
                    colors: <Color>[
                      effective.primary.withValues(alpha: 0.28),
                      effective.secondary.withValues(alpha: 0.2),
                      effective.accent.withValues(alpha: 0.22),
                    ],
                  ),
                ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      radius: 1.05,
                      colors: <Color>[
                        Color(0x00000000),
                        Color(0x59000000),
                      ],
                      stops: <double>[0.55, 1.0],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _FloatingOrbsPainter extends CustomPainter {
  _FloatingOrbsPainter({
    required this.center1,
    required this.center2,
    required this.center3,
    required this.colors,
  });

  final Offset center1;
  final Offset center2;
  final Offset center3;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint();

    void drawOrb(Offset center, Color color, double radiusFactor) {
      final Offset c = Offset(center.dx * size.width, center.dy * size.height);
      final double radius = min(size.width, size.height) * radiusFactor;
      final Rect rect = Rect.fromCircle(center: c, radius: radius);
      final Gradient grad = RadialGradient(
        colors: <Color>[
          color,
          color.withValues(alpha: 0.0),
        ],
        stops: const <double>[0.0, 1.0],
      );
      paint.shader = grad.createShader(rect);
      canvas.drawCircle(c, radius, paint);
    }

    drawOrb(center1, colors[0], 0.3);
    drawOrb(center2, colors[1], 0.24);
    drawOrb(center3, colors[2], 0.2);
  }

  @override
  bool shouldRepaint(covariant _FloatingOrbsPainter oldDelegate) {
    return oldDelegate.center1 != center1 ||
        oldDelegate.center2 != center2 ||
        oldDelegate.center3 != center3 ||
        oldDelegate.colors != colors;
  }
}
