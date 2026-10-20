import 'package:flutter/material.dart';

import '../../../../data/models/planet.dart';
import 'scene_painters.dart';

/// Тематический анимированный фон «внутреннего мира» планеты.
///
/// Один [AnimationController] гоняет фазу `0..1` для всех сцен, а конкретную
/// композицию (вода, город, эквалайзер, звёзды и т.д.) рисует соответствующий
/// художник из [scenePainterFor]. Слой обёрнут в [RepaintBoundary] и уважает
/// системную настройку «уменьшить движение».
class PlanetSceneBackground extends StatefulWidget {
  const PlanetSceneBackground({
    super.key,
    required this.scene,
    required this.primary,
    required this.secondary,
    required this.accent,
  });

  final PlanetScene scene;
  final Color primary;
  final Color secondary;
  final Color accent;

  @override
  State<PlanetSceneBackground> createState() => _PlanetSceneBackgroundState();
}

class _PlanetSceneBackgroundState extends State<PlanetSceneBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 16),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bool reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduceMotion) {
      if (_controller.isAnimating) _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, Widget? child) {
          return CustomPaint(
            size: Size.infinite,
            painter: scenePainterFor(
              scene: widget.scene,
              t: _controller.value,
              primary: widget.primary,
              secondary: widget.secondary,
              accent: widget.accent,
            ),
          );
        },
      ),
    );
  }
}
