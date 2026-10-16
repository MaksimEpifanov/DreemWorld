import 'package:flutter/material.dart';

import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import 'glow_container.dart';

/// Стеклянно-неоновая карточка с мягким свечением.
class NeonCard extends StatelessWidget {
  const NeonCard({
    super.key,
    required this.child,
    this.color,
    this.glow = true,
    this.padding = AppSpacing.card,
    this.onTap,
  });

  final Widget child;

  /// Акцентный цвет свечения. Если не указан — берётся `primary` из темы.
  final Color? color;

  /// Включить неоновое свечение.
  final bool glow;

  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color accent = color ?? scheme.primary;
    final Color secondary = scheme.secondary;

    final Widget card = Container(
      decoration: BoxDecoration(
        borderRadius: AppRadius.lgAll,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            accent.withValues(alpha: glow ? 0.55 : 0.25),
            secondary.withValues(alpha: glow ? 0.4 : 0.18),
          ],
        ),
        boxShadow: glow
            ? <BoxShadow>[
                BoxShadow(
                  color: accent.withValues(alpha: 0.35),
                  blurRadius: 24,
                  spreadRadius: 1,
                ),
                BoxShadow(
                  color: secondary.withValues(alpha: 0.2),
                  blurRadius: 40,
                  spreadRadius: -4,
                ),
              ]
            : null,
      ),
      padding: const EdgeInsets.all(1.2),
      child: GlowContainer(
        color: accent,
        glowRadius: glow ? 14 : 0,
        glowOpacity: glow ? 0.28 : 0,
        borderColor: accent.withValues(alpha: glow ? 0.55 : 0.3),
        background: scheme.surface.withValues(alpha: glow ? 0.88 : 0.96),
        borderRadius: AppRadius.lgAll,
        padding: padding,
        child: child,
      ),
    );

    if (onTap == null) return card;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: card,
    );
  }
}
