import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/index.dart';
import '../../../core/widgets/index.dart';
import '../../../data/models/planet.dart';
import '../../../data/providers/planet_providers.dart';
import 'widgets/galaxy_header.dart';
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
              SliverToBoxAdapter(child: GalaxyHeader(planets: planets)),
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
                        .animate(delay: (40 * index).ms)
                        .fadeIn(duration: 360.ms)
                        .slideY(
                          begin: 0.1,
                          end: 0,
                          duration: 440.ms,
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
