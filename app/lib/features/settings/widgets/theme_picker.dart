import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/index.dart';
import '../../../core/widgets/index.dart';

/// Выбор одной из 5 неоновых тем Dreem World.
///
/// Каждая тема показана крупной карточкой с превью-палитрой
/// (три цветных кружка) и неоновым индикатором активной темы.
class ThemePicker extends ConsumerWidget {
  const ThemePicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppThemeName selected = ref.watch(themeControllerProvider);

    return Column(
      children: <Widget>[
        for (final AppThemeName theme in AppThemeName.values)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _ThemeTile(theme: theme, selected: theme == selected),
          ),
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

    return Semantics(
      button: true,
      selected: selected,
      label: palette.title,
      child: InkWell(
        borderRadius: AppRadius.lgAll,
        onTap: () => ref.read(themeControllerProvider.notifier).setTheme(theme),
        child: GlowContainer(
          color: palette.primary,
          glowRadius: selected ? 22 : 0,
          glowOpacity: selected ? 0.5 : 0,
          borderColor: selected
              ? palette.primary
              : palette.primary.withValues(alpha: 0.25),
          background: palette.surface,
          borderRadius: AppRadius.lgAll,
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: <Widget>[
              _PalettePreview(palette: palette),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      palette.title,
                      style: AppTextStyles.title(color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: <Widget>[
                        _Swatch(color: palette.primary),
                        const SizedBox(width: AppSpacing.sm),
                        _Swatch(color: palette.secondary),
                        const SizedBox(width: AppSpacing.sm),
                        _Swatch(color: palette.accent),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              _ActiveIndicator(palette: palette, selected: selected),
            ],
          ),
        ),
      ),
    );
  }
}

/// Крупное превью палитры: градиент темы со свечением.
class _PalettePreview extends StatelessWidget {
  const _PalettePreview({required this.palette});

  final NeonPalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        borderRadius: AppRadius.mdAll,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            palette.primary,
            palette.secondary,
            palette.accent,
          ],
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: palette.glow.withValues(alpha: 0.6),
            blurRadius: 16,
            spreadRadius: 1,
          ),
        ],
      ),
      child: const Icon(Icons.auto_awesome, color: AppColors.white, size: 24),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.7),
          width: 1,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(color: color.withValues(alpha: 0.8), blurRadius: 10),
        ],
      ),
    );
  }
}

/// Неоновый индикатор активной темы.
class _ActiveIndicator extends StatelessWidget {
  const _ActiveIndicator({required this.palette, required this.selected});

  final NeonPalette palette;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected
            ? palette.primary
            : palette.primary.withValues(alpha: 0.08),
        boxShadow: selected
            ? <BoxShadow>[
                BoxShadow(
                  color: palette.glow.withValues(alpha: 0.8),
                  blurRadius: 16,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Icon(
        selected ? Icons.check_rounded : Icons.circle_outlined,
        size: 18,
        color: selected ? palette.onPrimary : palette.primary,
      ),
    );
  }
}
