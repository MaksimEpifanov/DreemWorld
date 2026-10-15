import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/index.dart';
import '../../../core/widgets/index.dart';

/// Выбор одной из 5 неоновых тем Dreem World.
class ThemePicker extends ConsumerWidget {
  const ThemePicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppThemeName selected = ref.watch(themeControllerProvider);

    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: <Widget>[
        for (final AppThemeName theme in AppThemeName.values)
          _ThemeTile(theme: theme, selected: theme == selected),
      ],
    );
  }
}

class _ThemeTile extends ConsumerWidget {
  const _ThemeTile({required this.theme, required this.selected});

  final AppThemeName theme;
  final bool selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final NeonPalette palette = theme.palette;
    final bool light = palette.onPrimary == AppColors.black;

    return Semantics(
      button: true,
      selected: selected,
      label: palette.title,
      child: InkWell(
        borderRadius: AppRadius.mdAll,
        onTap: () => ref.read(themeControllerProvider.notifier).setTheme(theme),
        child: GlowContainer(
          color: palette.primary,
          glowRadius: selected ? 18 : 0,
          glowOpacity: selected ? 0.45 : 0,
          borderColor: selected
              ? palette.primary
              : palette.primary.withValues(alpha: 0.3),
          background: palette.surface,
          borderRadius: AppRadius.mdAll,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm + 2,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: palette.primary,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: palette.glow.withValues(alpha: 0.7),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: selected
                    ? Icon(
                        Icons.check_rounded,
                        size: 18,
                        color: palette.onPrimary,
                      )
                    : null,
              ),
              const SizedBox(width: AppSpacing.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    palette.title,
                    style: AppTextStyles.label(color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      _Swatch(color: palette.primary, light: light),
                      const SizedBox(width: AppSpacing.xs),
                      _Swatch(color: palette.secondary, light: light),
                      const SizedBox(width: AppSpacing.xs),
                      _Swatch(color: palette.accent, light: light),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.color, required this.light});

  final Color color;
  final bool light;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: light ? AppColors.black : AppColors.white,
          width: 0.6,
        ),
      ),
    );
  }
}
