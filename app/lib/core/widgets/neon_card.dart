import 'package:flutter/material.dart';

import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import 'glow_container.dart';

/// Карточка с неоновой рамкой и свечением.
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

  /// Акцентный цвет рамки/свечения. По умолчанию — primary темы.
  final Color? color;

  /// Включить свечение.
  final bool glow;

  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color accent = color ?? Theme.of(context).colorScheme.primary;
    final Color surface = Theme.of(context).colorScheme.surface;

    final Widget card = GlowContainer(
      color: accent,
      glowRadius: glow ? 16 : 0,
      glowOpacity: glow ? 0.3 : 0,
      borderColor: accent.withValues(alpha: glow ? 0.55 : 0.3),
      background: surface,
      borderRadius: AppRadius.lgAll,
      padding: padding,
      child: child,
    );

    if (onTap == null) return card;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: card,
    );
  }
}
