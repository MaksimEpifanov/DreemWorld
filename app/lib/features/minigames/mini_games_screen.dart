import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/index.dart';
import '../../core/widgets/index.dart';
import '../wallet/wallet_controller.dart';

/// Экран мини-игр: внутриигровая валюта за входы и игры.
class MiniGamesScreen extends ConsumerStatefulWidget {
  const MiniGamesScreen({super.key});

  @override
  ConsumerState<MiniGamesScreen> createState() => _MiniGamesScreenState();
}

class _MiniGamesScreenState extends ConsumerState<MiniGamesScreen> {
  bool _spinning = false;

  Future<void> _claimBonus() async {
    final int reward = await ref.read(walletProvider.notifier).claimDaily();
    if (!mounted) return;
    if (reward > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Бонус за вход: +$reward монет')),
      );
    }
  }

  Future<void> _spin() async {
    if (_spinning) return;
    setState(() => _spinning = true);
    await Future<void>.delayed(const Duration(milliseconds: 1100));
    final int reward = 5 + Random().nextInt(46); // 5..50
    await ref.read(walletProvider.notifier).reward(reward);
    if (!mounted) return;
    setState(() => _spinning = false);
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        final ColorScheme scheme = Theme.of(context).colorScheme;
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text('Колесо удачи'),
          content: Text(
            'Вы выиграли $reward монет!',
            style: AppTextStyles.bodyBold(),
          ),
          actions: <Widget>[
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: scheme.primary),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Отлично'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final WalletState wallet = ref.watch(walletProvider);
    final WalletController controller = ref.read(walletProvider.notifier);

    return Scaffold(
      appBar: NeonAppBar(
        title: 'Мини-игры',
        leading: BackButton(onPressed: () => context.go('/main')),
      ),
      body: SafeArea(
        child: ResponsiveContent(
          child: ListView(
            padding: AppSpacing.page,
            children: <Widget>[
              _BalanceCard(wallet: wallet),
              const SizedBox(height: AppSpacing.md),
              if (controller.canClaimDaily)
                NeonButton(
                  label: 'Забрать бонус за вход +${controller.dailyBonus}',
                  icon: Icons.card_giftcard_rounded,
                  expanded: true,
                  onPressed: _claimBonus,
                )
              else
                GlassCard(
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.check_circle_outline_rounded,
                        color: scheme.secondary,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'Бонус за сегодня получен. Возвращайтесь завтра!',
                          style: AppTextStyles.caption(),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: AppSpacing.lg),
              Text('Игры', style: AppTextStyles.title()),
              const SizedBox(height: AppSpacing.sm),
              _GameCard(
                icon: Icons.casino_rounded,
                title: 'Колесо удачи',
                subtitle: 'Крутите и получайте монеты',
                actionLabel: _spinning ? 'Крутим…' : 'Крутить',
                onPlay: _spinning ? null : _spin,
              ),
              const SizedBox(height: AppSpacing.sm),
              const _GameCard(
                icon: Icons.grid_3x3_rounded,
                title: 'Три в ряд',
                subtitle: 'Собирайте линии и получайте монеты',
              ),
              const SizedBox(height: AppSpacing.sm),
              const _GameCard(
                icon: Icons.quiz_rounded,
                title: 'Викторина',
                subtitle: 'Отвечайте на вопросы по интересам',
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'За частые входы начисляется внутриигровая валюта. '
                'Новые игры появятся в следующих обновлениях.',
                style: AppTextStyles.caption(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.wallet});

  final WalletState wallet;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return GlassCard(
      child: Row(
        children: <Widget>[
          Icon(
            Icons.monetization_on_rounded,
            size: 40,
            color: scheme.tertiary,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Ваш баланс', style: AppTextStyles.caption()),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  '${wallet.balance} монет',
                  style: AppTextStyles.headline(),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                'серия входов',
                style: AppTextStyles.caption(color: scheme.secondary),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text('${wallet.streak}', style: AppTextStyles.bodyBold()),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 320.ms).slideY(begin: 0.06);
  }
}

class _GameCard extends StatelessWidget {
  const _GameCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onPlay,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onPlay;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return GlassCard(
      child: Row(
        children: <Widget>[
          Icon(icon, size: 32, color: scheme.primary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: AppTextStyles.bodyBold()),
                const SizedBox(height: AppSpacing.xxs),
                Text(subtitle, style: AppTextStyles.caption()),
              ],
            ),
          ),
          if (actionLabel != null)
            NeonButton(
              label: actionLabel!,
              onPressed: onPlay,
            )
          else
            Text(
              'скоро',
              style: AppTextStyles.label(color: AppColors.textMuted),
            ),
        ],
      ),
    );
  }
}
