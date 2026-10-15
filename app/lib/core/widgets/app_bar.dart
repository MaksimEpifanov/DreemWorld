import 'package:flutter/material.dart';

import '../theme/app_radius.dart';
import '../theme/app_text_styles.dart';

/// Неоновый AppBar с тонкой акцентной линией внизу.
class NeonAppBar extends StatelessWidget implements PreferredSizeWidget {
  const NeonAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.showGlowLine = true,
  });

  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showGlowLine;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).colorScheme.primary;

    return AppBar(
      title: Text(title, style: AppTextStyles.headline()),
      actions: actions,
      leading: leading,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      bottom: showGlowLine
          ? PreferredSize(
              preferredSize: const Size.fromHeight(2),
              child: Container(
                height: 2,
                decoration: BoxDecoration(
                  borderRadius: AppRadius.pillAll,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: primary.withValues(alpha: 0.6),
                      blurRadius: 8,
                    ),
                  ],
                  gradient: LinearGradient(
                    colors: <Color>[
                      primary.withValues(alpha: 0),
                      primary,
                      primary.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            )
          : null,
    );
  }
}
