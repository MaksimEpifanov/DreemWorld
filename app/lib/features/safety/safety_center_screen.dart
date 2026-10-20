import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/index.dart';
import '../../core/widgets/index.dart';
import '../../data/models/safety.dart';
import 'safety_controller.dart';

/// Центр безопасности: правила, мои жалобы и заблокированные пользователи.
class SafetyCenterScreen extends ConsumerWidget {
  const SafetyCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final SafetyState safety = ref.watch(safetyProvider);
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: NeonAppBar(
        title: 'Центр безопасности',
        leading: BackButton(onPressed: () => context.go('/settings')),
      ),
      body: SafeArea(
        child: ResponsiveContent(
          child: ListView(
            padding: AppSpacing.page,
            children: <Widget>[
              GlassCard(
                child: Row(
                  children: <Widget>[
                    Icon(Icons.shield_moon_rounded, size: 40, color: scheme.secondary),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('Мы защищаем вас', style: AppTextStyles.title()),
                          const SizedBox(height: AppSpacing.xxs),
                          Text(
                            'ИИ-фильтр проверяет сообщения и профили, а жалобы '
                            'уходят модераторам.',
                            style: AppTextStyles.caption(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Основные правила', style: AppTextStyles.title()),
              const SizedBox(height: AppSpacing.sm),
              const _RuleTile(
                emoji: '🙅',
                title: 'Никакого контента 18+',
                subtitle: 'Сексуализация, домогательства и «интим-услуги» запрещены.',
              ),
              const _RuleTile(
                emoji: '🛡️',
                title: 'Защита несовершеннолетних',
                subtitle: 'Личные чаты детей и взрослых заблокированы автоматически.',
              ),
              const _RuleTile(
                emoji: '💸',
                title: 'Ноль терпимости к мошенникам',
                subtitle: 'Переводы денег, «быстрый заработок» и фишинг — бан.',
              ),
              const _RuleTile(
                emoji: '😡',
                title: 'Уважение и вежливость',
                subtitle: 'Угрозы, травля и оскорбления ведут к блокировке.',
              ),
              const _RuleTile(
                emoji: '🚨',
                title: 'Сообщайте о проблемах',
                subtitle: 'Кнопка «Пожаловаться» есть у профилей, сообщений и фото.',
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: <Widget>[
                  Text('Мои жалобы', style: AppTextStyles.title()),
                  const Spacer(),
                  Text('${safety.reports.length}', style: AppTextStyles.caption()),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              if (safety.reports.isEmpty)
                Text(
                  'Вы пока ни на кого не жаловались.',
                  style: AppTextStyles.caption(),
                )
              else
                for (final Report report in safety.reports)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: _ReportTile(report: report),
                  ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: <Widget>[
                  Text('Заблокированные', style: AppTextStyles.title()),
                  const Spacer(),
                  Text('${safety.blocked.length}', style: AppTextStyles.caption()),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              if (safety.blocked.isEmpty)
                Text('Список пуст.', style: AppTextStyles.caption())
              else
                for (final BlockedUser user in safety.blocked)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: _BlockedTile(
                      user: user,
                      onUnblock: () =>
                          ref.read(safetyProvider.notifier).unblock(user.userId),
                    ),
                  ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Если вы в опасности, обратитесь в полицию. '
                'В критической ситуации звоните 112.',
                style: AppTextStyles.caption(color: AppColors.error),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RuleTile extends StatelessWidget {
  const _RuleTile({
    required this.emoji,
    required this.title,
    required this.subtitle,
  });

  final String emoji;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: GlassCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(emoji, style: const TextStyle(fontSize: 24)),
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
          ],
        ),
      ),
    );
  }
}

class _ReportTile extends StatelessWidget {
  const _ReportTile({required this.report});

  final Report report;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return GlassCard(
      child: Row(
        children: <Widget>[
          Text(report.reason.emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(report.targetName, style: AppTextStyles.bodyBold()),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  '${report.target.label} · ${report.reason.label}',
                  style: AppTextStyles.caption(),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                '${report.status.emoji} ${report.status.label}',
                style: AppTextStyles.label(
                  color: report.status == ReportStatus.actionTaken
                      ? scheme.secondary
                      : scheme.primary,
                ),
              ),
              if (report.autoHidden)
                Text('скрыто', style: AppTextStyles.caption()),
            ],
          ),
        ],
      ),
    );
  }
}

class _BlockedTile extends StatelessWidget {
  const _BlockedTile({required this.user, required this.onUnblock});

  final BlockedUser user;
  final VoidCallback onUnblock;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(user.name, style: AppTextStyles.bodyBold()),
                if ((user.reason ?? '').isNotEmpty)
                  Text(user.reason!, style: AppTextStyles.caption()),
              ],
            ),
          ),
          TextButton(
            onPressed: onUnblock,
            child: const Text('Разблокировать'),
          ),
        ],
      ),
    );
  }
}
