import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/index.dart';
import '../../../core/widgets/index.dart';
import '../../../data/models/planet.dart';
import '../../../data/providers/planet_providers.dart';
import 'widgets/planet_card.dart';

/// Главный экран: планеты-сообщества по интересам.
///
/// Каждая планета объединяет людей с общим увлечением. Касание планеты
/// открывает её «внутренний мир» с оформлением под специфику хобби.
class PlanetHomeScreen extends ConsumerWidget {
  const PlanetHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<Planet> planets = ref.watch(planetsProvider);

    return Scaffold(
      appBar: const NeonAppBar(title: 'Dreem World'),
      body: SafeArea(
        child: ResponsiveContent(
          child: CustomScrollView(
            slivers: <Widget>[
              const SliverToBoxAdapter(child: _HomeHeader()),
              SliverPadding(
                padding: AppSpacing.page,
                sliver: SliverGrid(
                  gridDelegate:
                      const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 280,
                        mainAxisSpacing: AppSpacing.md,
                        crossAxisSpacing: AppSpacing.md,
                        childAspectRatio: 0.78,
                      ),
                  delegate: SliverChildBuilderDelegate((
                    BuildContext context,
                    int index,
                  ) {
                    final Planet planet = planets[index];
                    return PlanetCard(
                      planet: planet,
                      onTap: () => context.go('/main/planet/${planet.id}'),
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

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          NeonGradientText(
            'Выбери свою планету',
            gradient: LinearGradient(
              colors: <Color>[
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
              ],
            ),
            style: AppTextStyles.display(),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Планеты объединяют людей по интересам. Заходи и находи своих.',
            style: AppTextStyles.body(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
