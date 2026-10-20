import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/index.dart';
import '../../core/widgets/index.dart';

/// Экран мини-игр: вход в игры за внутриигровую валюту.
///
/// Пока заглушка: карточки игр и баланс появятся вместе с системой валюты.
class MiniGamesScreen extends StatelessWidget {
  const MiniGamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

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
              GlassCard(
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
                            '0 монет',
                            style: AppTextStyles.headline(),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'за входы',
                      style: AppTextStyles.caption(color: scheme.secondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Скоро здесь', style: AppTextStyles.title()),
              const SizedBox(height: AppSpacing.sm),
              const _GameCard(
                icon: Icons.grid_3x3_rounded,
                title: 'Три в ряд',
                subtitle: 'Собирайте линии и получайте монеты',
              ),
              const SizedBox(height: AppSpacing.sm),
              const _GameCard(
                icon: Icons.casino_rounded,
                title: 'Колесо удачи',
                subtitle: 'Ежедневный бесплатный прокрут',
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
                'Игры и баланс появятся в следующих обновлениях.',
                style: AppTextStyles.caption(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  const _GameCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

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
          Text(
            'скоро',
            style: AppTextStyles.label(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
