import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/index.dart';
import '../../../../core/widgets/index.dart';
import '../../../../data/models/planet.dart';
import '../../home/widgets/planet_card.dart';

/// Переиспользуемое тело каталога планет: заголовок и сетка карточек.
class PlanetCatalogBody extends StatelessWidget {
  const PlanetCatalogBody({
    super.key,
    required this.planets,
    required this.title,
    required this.subtitle,
  });

  final List<Planet> planets;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NeonAppBar(
        title: title,
        leading: BackButton(onPressed: () => context.go('/main')),
      ),
      body: SafeArea(
        child: ResponsiveContent(
          child: planets.isEmpty
              ? Center(
                  child: Padding(
                    padding: AppSpacing.page,
                    child: Text(
                      'Здесь пока нет планет',
                      style: AppTextStyles.body(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                )
              : CustomScrollView(
                  slivers: <Widget>[
                    SliverPadding(
                      padding: AppSpacing.page,
                      sliver: SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.only(
                            bottom: AppSpacing.md,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              NeonGradientText(
                                title,
                                gradient: LinearGradient(
                                  colors: <Color>[
                                    Theme.of(context).colorScheme.primary,
                                    Theme.of(context).colorScheme.secondary,
                                  ],
                                ),
                                style: AppTextStyles.headline(),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                subtitle,
                                style: AppTextStyles.body(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: AppSpacing.page,
                      sliver: SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 280,
                              mainAxisSpacing: AppSpacing.md,
                              crossAxisSpacing: AppSpacing.md,
                              childAspectRatio: 0.74,
                            ),
                        delegate: SliverChildBuilderDelegate((
                          BuildContext context,
                          int index,
                        ) {
                          final Planet planet = planets[index];
                          return PlanetCard(
                                planet: planet,
                                onTap: () => context.go(
                                  '/main/planet/${planet.id}',
                                ),
                              )
                              .animate(delay: (30 * index).ms)
                              .fadeIn(duration: 300.ms)
                              .slideY(
                                begin: 0.1,
                                end: 0,
                                duration: 400.ms,
                                curve: Curves.easeOutCubic,
                              );
                        }, childCount: planets.length),
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: AppSpacing.xxl),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
