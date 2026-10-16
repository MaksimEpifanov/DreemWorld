import 'package:flutter/material.dart';

import '../theme/app_radius.dart';

/// Контейнер с усиленным неоновым свечением.
class GlowContainer extends StatelessWidget {
  const GlowContainer({
    super.key,
    required this.child,
    required this.color,
    this.glowRadius = 18,
    this.glowOpacity = 0.45,
    this.borderColor,
    this.background,
    this.borderRadius = AppRadius.lgAll,
    this.padding = EdgeInsets.zero,
    this.margin = EdgeInsets.zero,
  });

  final Widget child;
  final Color color;
  final double glowRadius;
  final double glowOpacity;
  final Color? borderColor;
  final Color? background;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    final bool glowing = glowRadius > 0 && glowOpacity > 0;
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: background,
        borderRadius: borderRadius,
        border: borderColor != null ? Border.all(color: borderColor!) : null,
        boxShadow: glowing
            ? <BoxShadow>[
                BoxShadow(
                  color: color.withValues(alpha: glowOpacity),
                  blurRadius: glowRadius * 1.2,
                  spreadRadius: glowRadius / 5,
                ),
                BoxShadow(
                  color: color.withValues(alpha: glowOpacity * 0.6),
                  blurRadius: glowRadius * 2.2,
                  spreadRadius: glowRadius / 12,
                ),
                BoxShadow(
                  color: color.withValues(alpha: glowOpacity * 0.3),
                  blurRadius: glowRadius * 3,
                  spreadRadius: -glowRadius / 8,
                ),
              ]
            : null,
      ),
      child: child,
    );
  }
}
