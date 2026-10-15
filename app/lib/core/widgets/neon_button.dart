import 'package:flutter/material.dart';

import '../theme/app_radius.dart';
import 'glow_container.dart';

/// Вариант неоновой кнопки.
enum NeonButtonVariant { filled, outlined, ghost }

/// Неоновая кнопка с эффектом свечения.
class NeonButton extends StatelessWidget {
  const NeonButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.variant = NeonButtonVariant.filled,
    this.color,
    this.isLoading = false,
    this.expanded = false,
  });

  final VoidCallback? onPressed;
  final String label;
  final IconData? icon;
  final NeonButtonVariant variant;
  final Color? color;
  final bool isLoading;

  /// Растянуть кнопку по ширине родителя.
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color accent = color ?? theme.colorScheme.primary;
    final bool enabled = onPressed != null && !isLoading;
    final Color contentColor =
        variant == NeonButtonVariant.filled ? theme.colorScheme.onPrimary : accent;

    final Widget button = switch (variant) {
      NeonButtonVariant.filled => FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: accent,
            foregroundColor: contentColor,
            disabledBackgroundColor: accent.withValues(alpha: 0.25),
            disabledForegroundColor: contentColor.withValues(alpha: 0.5),
            shape: const RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
          ),
          child: _content(contentColor),
        ),
      NeonButtonVariant.outlined => OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: accent,
            disabledForegroundColor: accent.withValues(alpha: 0.5),
            side: BorderSide(color: accent.withValues(alpha: 0.8)),
            shape: const RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
          ),
          child: _content(contentColor),
        ),
      NeonButtonVariant.ghost => TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            foregroundColor: accent,
            disabledForegroundColor: accent.withValues(alpha: 0.5),
            shape: const RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
          ),
          child: _content(contentColor),
        ),
    };

    final Widget result = GlowContainer(
      color: accent,
      glowRadius: enabled ? 16 : 0,
      glowOpacity: enabled ? 0.35 : 0,
      borderRadius: AppRadius.mdAll,
      child: button,
    );

    if (expanded) return SizedBox(width: double.infinity, child: result);
    return result;
  }

  Widget _content(Color contentColor) {
    if (isLoading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: contentColor,
        ),
      );
    }
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(label),
        ],
      );
    }
    return Text(label);
  }
}
