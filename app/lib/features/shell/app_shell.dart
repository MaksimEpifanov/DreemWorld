import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/index.dart';

/// Каркас основного интерфейса с нижней навигацией по разделам.
///
/// Оборачивает [StatefulNavigationShell] из `StatefulShellRoute.indexedStack`:
/// каждая вкладка хранит собственную историю переходов.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.shell});

  /// Навигационная оболочка ветки StatefulShellRoute.
  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: AppNavigationBar(
        currentIndex: shell.currentIndex,
        onDestinationSelected: (int index) {
          shell.goBranch(
            index,
            initialLocation: index == shell.currentIndex,
          );
        },
      ),
    );
  }
}

/// Стеклянный неоновый бар с четырьмя разделами.
class AppNavigationBar extends StatelessWidget {
  const AppNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
  });

  /// Индекс активного раздела.
  final int currentIndex;

  /// Колбэк переключения раздела.
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: BoxDecoration(
            color: scheme.surface.withValues(alpha: 0.72),
            border: Border(
              top: BorderSide(
                color: scheme.primary.withValues(alpha: 0.35),
              ),
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: scheme.primary.withValues(alpha: 0.28),
                blurRadius: 28,
                spreadRadius: -6,
              ),
            ],
          ),
          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              backgroundColor: Colors.transparent,
              elevation: 0,
              indicatorColor: scheme.primary.withValues(alpha: 0.22),
              indicatorShape: const RoundedRectangleBorder(
                borderRadius: AppRadius.pillAll,
              ),
              labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
                (Set<WidgetState> states) => AppTextStyles.label(
                  color: states.contains(WidgetState.selected)
                      ? scheme.primary
                      : AppColors.textSecondary,
                ),
              ),
              iconTheme: WidgetStateProperty.resolveWith<IconThemeData>(
                (Set<WidgetState> states) => IconThemeData(
                  color: states.contains(WidgetState.selected)
                      ? scheme.primary
                      : AppColors.textSecondary,
                ),
              ),
            ),
            child: NavigationBar(
              selectedIndex: currentIndex,
              onDestinationSelected: onDestinationSelected,
              height: 72,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              backgroundColor: Colors.transparent,
              destinations: <NavigationDestination>[
                NavigationDestination(
                  icon: const Icon(Icons.explore_outlined),
                  selectedIcon: _glowingIcon(Icons.explore, scheme),
                  label: 'Подбор',
                ),
                NavigationDestination(
                  icon: const Icon(Icons.chat_bubble_outline),
                  selectedIcon: _glowingIcon(Icons.chat_bubble, scheme),
                  label: 'Чаты',
                ),
                NavigationDestination(
                  icon: const Icon(Icons.person_outline),
                  selectedIcon: _glowingIcon(Icons.person, scheme),
                  label: 'Профиль',
                ),
                NavigationDestination(
                  icon: const Icon(Icons.settings_outlined),
                  selectedIcon: _glowingIcon(Icons.settings, scheme),
                  label: 'Настройки',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Icon _glowingIcon(IconData icon, ColorScheme scheme) {
    final Color glow = scheme.shadow;
    return Icon(
      icon,
      color: scheme.primary,
      shadows: <Shadow>[
        Shadow(color: glow.withValues(alpha: 0.9), blurRadius: 16),
        Shadow(color: glow.withValues(alpha: 0.6), blurRadius: 28),
      ],
    );
  }
}
