import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/index.dart';
import '../../../core/widgets/index.dart';
import '../../../data/models/planet.dart';
import '../../../data/providers/planet_providers.dart';
import '../home/widgets/planet_card.dart';

/// Экран «Все планеты»: полный каталог сообществ по интересам.
class PlanetsCatalogScreen extends ConsumerWidget {
  const PlanetsCatalogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<Planet> planets = ref.watch(planetsProvider);

    return Scaffold(
      appBar: NeonAppBar(
        title: 'Все планеты',
        leading: BackButton(onPressed: () => context.go('/main')),
      ),
      body: SafeArea(
        child: ResponsiveContent(
          child: CustomScrollView(
            slivers: <Widget>[
              SliverPadding(
                padding: AppSpacing.page,
                sliver: SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        NeonGradientText(
                          'Все миры по интересам',
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
                          'Выберите планету — и загляните в её мир.',
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
                          onTap: () => context.go('/main/planet/${planet.id}'),
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
