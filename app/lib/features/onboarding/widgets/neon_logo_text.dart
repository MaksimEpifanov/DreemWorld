import 'package:flutter/material.dart';

import '../../../core/theme/index.dart';

class NeonLogoText extends StatelessWidget {
  const NeonLogoText({
    super.key,
    this.text = 'Dreem World',
    this.fontSize = 48,
    this.glowColor,
  });

  final String text;
  final double fontSize;
  final Color? glowColor;

  @override
  Widget build(BuildContext context) {
    final Color color = glowColor ?? Theme.of(context).colorScheme.primary;
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return LinearGradient(
          colors: <Color>[color, color.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(bounds);
      },
      blendMode: BlendMode.srcATop,
      child: Text(
        text,
        style: AppTextStyles.display(color: color).copyWith(
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
          letterSpacing: 2,
          shadows: <Shadow>[
            Shadow(
              blurRadius: 24,
              color: color.withValues(alpha: 0.8),
            ),
            Shadow(
              blurRadius: 48,
              color: color.withValues(alpha: 0.4),
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
