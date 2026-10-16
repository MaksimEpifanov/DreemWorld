import 'package:flutter/material.dart';

/// Текст с градиентной заливкой и неоновым свечением.
///
/// Свечение рисуется отдельным слоем [RichText] позади [ShaderMask], поэтому
/// его цвет ([glowColor]) не перетирается градиентной маской.
class NeonGradientText extends StatelessWidget {
  const NeonGradientText(
    this.text, {
    super.key,
    required this.gradient,
    this.style,
    this.textAlign,
    this.glowColor,
    this.glowRadius = 12,
  });

  final String text;
  final Gradient gradient;
  final TextStyle? style;
  final TextAlign? textAlign;
  final Color? glowColor;
  final double glowRadius;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle base = style ?? theme.textTheme.titleLarge ?? const TextStyle();
    final Color glow = glowColor ?? theme.colorScheme.primary;

    final TextStyle glowStyle = base.copyWith(
      color: Colors.transparent,
      shadows: <Shadow>[
        Shadow(color: glow.withValues(alpha: 0.7), blurRadius: glowRadius),
        Shadow(color: glow.withValues(alpha: 0.4), blurRadius: glowRadius * 2),
      ],
    );

    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        RichText(
          textAlign: textAlign ?? TextAlign.start,
          textDirection: Directionality.of(context),
          text: TextSpan(text: text, style: glowStyle),
        ),
        ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (Rect bounds) {
            return gradient.createShader(
              Rect.fromLTWH(0, 0, bounds.width, bounds.height),
            );
          },
          child: Text(
            text,
            style: base.copyWith(color: Colors.white),
            textAlign: textAlign,
          ),
        ),
      ],
    );
  }
}
