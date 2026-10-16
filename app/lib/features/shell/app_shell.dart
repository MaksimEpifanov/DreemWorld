import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/index.dart';

/// Оболочка с нижней навигацией для основных разделов приложения.
///
/// Использует [StatefulNavigationShell] из `StatefulShellRoute.indexedStack`:
/// состояние каждой вкладки (подбор, чаты, профиль, настройки)
/// сохраняется при переключении.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.shell});

  /// Корневой навигатор оболочки с ветками вкладок.
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
            // При повторном тапе на активную вкладку — возврат к её корню.
            initialLocation: index == shell.currentIndex,
          );
        },
      ),
    );
  }
}

/// Неоновая нижняя панель с четырьмя вкладками.
class AppNavigationBar extends StatelessWidget {
  const AppNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
  });

  /// Индекс активной вкладки.
  final int currentIndex;

  /// Вызывается при выборе вкладки по индексу.
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onDestinationSelected,
      backgroundColor: AppColors.surface,
      indicatorColor: scheme.primary.withValues(alpha: 0.2),
      height: 68,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      destinations: const <NavigationDestination>[
        NavigationDestination(
          icon: Icon(Icons.explore_outlined),
          selectedIcon: Icon(Icons.explore),
          label: 'Подбор',
        ),
        NavigationDestination(
          icon: Icon(Icons.chat_bubble_outline),
          selectedIcon: Icon(Icons.chat_bubble),
          label: 'Чаты',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Профиль',
        ),
        NavigationDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings),
          label: 'Настройки',
        ),
      ],
    );
  }
}
