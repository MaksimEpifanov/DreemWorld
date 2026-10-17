import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/index.dart';
import '../../../../data/models/planet.dart';

/// Живой неоновый «шар» планеты.
///
/// Состоит из пульсирующего гало, наклонённой орбиты со спутником и
/// многослойной сферы с бликом и контровым светом. Лёгкое парение и
/// вращение орбиты создают ощущение живого космического объекта.
class PlanetOrb extends StatelessWidget {
  const PlanetOrb({
    super.key,
    required this.planet,
    this.size = 96,
    this.animate = true,
  });

  final Planet planet;

  /// Диаметр сферы. Гало и орбита масштабируются относительно него.
  final double size;

  /// Отключает бесконечные анимации (используется в тестах).
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final double canvas = size * 1.42;
    return RepaintBoundary(
      child: SizedBox(
        width: canvas,
        height: canvas,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: <Widget>[
            _Halo(planet: planet, size: size, animate: animate),
            _Orbit(planet: planet, size: canvas, animate: animate),
            _Sphere(planet: planet, size: size, animate: animate),
          ],
        ),
      ),
    );
  }
}

/// Мягкое пульсирующее свечение вокруг сферы.
class _Halo extends StatelessWidget {
  const _Halo({
    required this.planet,
    required this.size,
    required this.animate,
  });

  final Planet planet;
  final double size;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final Widget halo = Container(
      width: size * 1.55,
      height: size * 1.55,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: <Color>[
            planet.primary.withValues(alpha: 0.5),
            planet.secondary.withValues(alpha: 0.2),
            AppColors.transparent,
          ],
          stops: const <double>[0.0, 0.45, 1.0],
        ),
      ),
    );
    if (!animate) return halo;

    return halo
        .animate(
          onPlay: (AnimationController controller) =>
              controller.repeat(reverse: true),
        )
        .scaleXY(
          begin: 0.9,
          end: 1.08,
          duration: 2600.ms,
          curve: Curves.easeInOut,
        )
        .fade(
          begin: 0.6,
          end: 1,
          duration: 2600.ms,
          curve: Curves.easeInOut,
        );
  }
}

/// Наклонённое кольцо орбиты со светящимся спутником, что медленно вращается.
class _Orbit extends StatelessWidget {
  const _Orbit({
    required this.planet,
    required this.size,
    required this.animate,
  });

  final Planet planet;
  final double size;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final double ringSize = size * 0.84;
    const double satellite = 7;

    final Widget orbit = Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.0012)
        ..rotateX(1.15)
        ..rotateZ(-0.4),
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Container(
              width: ringSize,
              height: ringSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: planet.accent.withValues(alpha: 0.35),
                  width: 1.1,
                ),
              ),
            ),
            Positioned(
              top: size / 2 - ringSize / 2 - satellite / 2,
              left: size / 2 - satellite / 2,
              child: Container(
                width: satellite,
                height: satellite,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: planet.accent,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: planet.accent.withValues(alpha: 0.9),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
    if (!animate) return orbit;

    return orbit
        .animate(
          onPlay: (AnimationController controller) => controller.repeat(),
        )
        .rotate(
          begin: 0,
          end: 1,
          duration: 16.seconds,
          curve: Curves.linear,
        );
  }
}

/// Многослойная сфера планеты: градиент, блик, контровой свет и эмодзи.
class _Sphere extends StatelessWidget {
  const _Sphere({
    required this.planet,
    required this.size,
    required this.animate,
  });

  final Planet planet;
  final double size;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final Widget sphere = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(-0.42, -0.5),
          radius: 1.05,
          colors: <Color>[
            Color.lerp(planet.secondary, AppColors.white, 0.55)!,
            planet.secondary,
            planet.primary,
            Color.lerp(planet.primary, AppColors.black, 0.5)!,
          ],
          stops: const <double>[0.0, 0.22, 0.62, 1.0],
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: planet.primary.withValues(alpha: 0.6),
            blurRadius: size * 0.6,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: planet.secondary.withValues(alpha: 0.35),
            blurRadius: size * 0.95,
          ),
        ],
      ),
      child: ClipOval(
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Align(
              alignment: const Alignment(-0.42, -0.48),
              child: Container(
                width: size * 0.34,
                height: size * 0.26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: <Color>[
                      AppColors.white.withValues(alpha: 0.85),
                      AppColors.white.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
            Align(
              alignment: const Alignment(0.42, 0.55),
              child: Container(
                width: size * 0.7,
                height: size * 0.34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: <Color>[
                      planet.accent.withValues(alpha: 0.4),
                      AppColors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Center(
              child: Text(
                planet.emoji,
                style: TextStyle(
                  fontSize: size * 0.42,
                  shadows: <Shadow>[
                    Shadow(
                      color: AppColors.black.withValues(alpha: 0.45),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
    if (!animate) return sphere;

    return sphere
        .animate(
          onPlay: (AnimationController controller) =>
              controller.repeat(reverse: true),
        )
        .moveY(
          begin: 2.5,
          end: -2.5,
          duration: 3000.ms,
          curve: Curves.easeInOut,
        );
  }
}
