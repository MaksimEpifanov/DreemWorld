import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/index.dart';
import '../../../../data/models/planet.dart';
import '../../../../data/models/planet_news.dart';
import '../../../../data/providers/planet_providers.dart';
import 'news_card.dart';

/// Секция «Новости планеты» для экрана планеты: первые новости ленты
/// и переход к полному списку.
class NewsSection extends ConsumerWidget {
  const NewsSection({super.key, required this.planet});

  final Planet planet;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<PlanetNewsItem>> newsAsync = ref.watch(
      planetNewsProvider(planet.id),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Icon(Icons.auto_awesome, size: 18, color: planet.accent),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text('Новости планеты', style: AppTextStyles.title()),
            ),
            TextButton(
              onPressed: () =>
                  context.go('/main/planet/${planet.id}/news'),
              child: Text(
                'Показывать все',
                style: AppTextStyles.label(color: planet.accent),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          'Лента обновляется каждый час ИИ-редакцией',
          style: AppTextStyles.caption(),
        ),
        const SizedBox(height: AppSpacing.sm),
        newsAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (Object error, StackTrace stackTrace) => Text(
            'Не удалось загрузить новости',
            style: AppTextStyles.body(color: AppColors.textMuted),
          ),
          data: (List<PlanetNewsItem> news) {
            if (news.isEmpty) {
              return Text(
                'Пока нет новостей',
                style: AppTextStyles.caption(),
              );
            }
            return Column(
              children: <Widget>[
                for (final PlanetNewsItem item in news.take(3))
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: NewsCard(
                      news: item,
                      planet: planet,
                      onTap: () =>
                          context.go('/main/planet/${planet.id}/news'),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
