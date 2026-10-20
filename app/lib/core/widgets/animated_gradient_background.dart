import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'cosmic_background.dart';

/// Глобальный слой: реалистичный фон глубокого космоса позади [child].
///
/// Рисует звёзды, туманности и галактики, добавляет лёгкий оттенок текущей
/// темы и мягкое затемнение для читаемости интерфейса поверх.
class AnimatedGradientBackgroundLayer extends StatelessWidget {
  const AnimatedGradientBackgroundLayer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final NeonPalette? palette =
        Theme.of(context).extension<NeonPaletteExtension>()?.palette;

    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: CosmicBackground(
            tint: palette?.primary,
            tintOpacity: 0.12,
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  radius: 1.1,
                  colors: <Color>[
                    Colors.black.withValues(alpha: 0.0),
                    const Color(0xFF020106).withValues(alpha: 0.45),
                  ],
                  stops: const <double>[0.5, 1.0],
                ),
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}
