import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/index.dart';
import '../../core/widgets/cosmic_background.dart';
import '../wallet/wallet_controller.dart';

/// Каркас основного интерфейса с нижней навигацией по разделам.
///
/// Оборачивает [StatefulNavigationShell] из `StatefulShellRoute.indexedStack`:
/// каждая вкладка хранит собственную историю переходов.
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.shell});

  /// Навигационная оболочка ветки StatefulShellRoute.
  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final WalletState wallet = ref.watch(walletProvider);
    return Scaffold(
      backgroundColor: const Color(0xFF050510),
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          const CosmicBackground(),
          SizedBox.expand(child: shell),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _MiniGamesBanner(
            balance: wallet.balance,
            onTap: () => context.go('/minigames'),
          ),
          AppNavigationBar(
            currentIndex: shell.currentIndex,
            onDestinationSelected: (int index) {
              shell.goBranch(
                index,
                initialLocation: index == shell.currentIndex,
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Плашка входа в мини-игры над нижним баром.
class _MiniGamesBanner extends StatelessWidget {
  const _MiniGamesBanner({required this.onTap, this.balance = 0});

  final VoidCallback onTap;
  final int balance;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.xs,
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            borderRadius: AppRadius.pillAll,
            gradient: LinearGradient(
              colors: <Color>[
                scheme.tertiary.withValues(alpha: 0.9),
                scheme.primary.withValues(alpha: 0.9),
              ],
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: scheme.tertiary.withValues(alpha: 0.45),
                blurRadius: 20,
                spreadRadius: -4,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(
                Icons.sports_esports_rounded,
                size: 20,
                color: Colors.white,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                balance > 0
                    ? 'Мини-игры · $balance монет'
                    : 'Мини-игры · заработай монеты',
                style: AppTextStyles.label(color: Colors.white),
              ),
            ],
          ),
        ),
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
                  icon: const Icon(Icons.public_outlined),
                  selectedIcon: _glowingIcon(Icons.public, scheme),
                  label: 'Главная',
                ),
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
                  icon: const Icon(Icons.people_outline),
                  selectedIcon: _glowingIcon(Icons.people, scheme),
                  label: 'Контакты',
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
