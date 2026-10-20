import 'package:flutter/material.dart';

import '../../../../core/theme/index.dart';
import '../../../../core/widgets/index.dart';
import '../../../../data/models/planet.dart';
import '../../../../data/models/planet_news.dart';

/// Карточка одной новости ленты планеты.
class NewsCard extends StatelessWidget {
  const NewsCard({
    super.key,
    required this.news,
    required this.planet,
    this.onTap,
  });

  final PlanetNewsItem news;
  final Planet planet;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: AppRadius.mdAll,
                  gradient: LinearGradient(
                    colors: <Color>[planet.primary, planet.secondary],
                  ),
                ),
                alignment: Alignment.center,
                child: Text(news.emoji, style: const TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      news.title,
                      style: AppTextStyles.bodyBold(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      '${news.sourceName} · ${relativeTime(news.publishedAt)}',
                      style: AppTextStyles.caption(),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            news.summary,
            style: AppTextStyles.body(color: AppColors.textSecondary),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: planet.accent.withValues(alpha: 0.12),
                  borderRadius: AppRadius.pillAll,
                ),
                child: Text(
                  '#${news.tag}',
                  style: AppTextStyles.label(color: planet.accent),
                ),
              ),
              const Spacer(),
              Icon(
                Icons.favorite_border_rounded,
                size: 16,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: AppSpacing.xxs),
              Text('${news.likes}', style: AppTextStyles.caption()),
            ],
          ),
        ],
      ),
    );
  }
}

/// Относительное время вида «5 мин назад», «2 ч назад».
String relativeTime(DateTime time, {DateTime? now}) {
  final DateTime reference = now ?? DateTime.now();
  final Duration diff = reference.difference(time);
  if (diff.inMinutes < 1) return 'только что';
  if (diff.inMinutes < 60) return '${diff.inMinutes} мин назад';
  if (diff.inHours < 24) return '${diff.inHours} ч назад';
  return '${diff.inDays} дн назад';
}
