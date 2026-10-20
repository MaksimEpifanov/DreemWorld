import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/index.dart';
import '../../../../core/widgets/index.dart';
import '../../../../data/models/planet.dart';
import '../../cosmos/orbital_catalog.dart';

/// Переиспользуемое тело каталога планет: заголовок и орбитальная карта.
///
/// Планеты показываются вокруг солнца по эллиптическим орбитам — как
/// настоящая солнечная система интересов.
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
      backgroundColor: AppColors.background,
      appBar: NeonAppBar(
        title: title,
        leading: BackButton(onPressed: () => context.go('/main')),
      ),
      body: SafeArea(
        child: planets.isEmpty
            ? Center(
                child: Padding(
                  padding: AppSpacing.page,
                  child: Text(
                    'Здесь пока нет планет',
                    style: AppTextStyles.body(color: AppColors.textSecondary),
                  ),
                ),
              )
            : Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.sm,
                      AppSpacing.md,
                      0,
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
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          subtitle,
                          style: AppTextStyles.body(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Row(
                          children: <Widget>[
                            Icon(
                              Icons.pinch_outlined,
                              size: 14,
                              color: AppColors.textMuted,
                            ),
                            const SizedBox(width: AppSpacing.xxs),
                            Text(
                              'Приблизьте карту и нажмите на планету',
                              style: AppTextStyles.caption(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: OrbitalCatalog(
                      planets: planets,
                      onPlanetTap: (Planet planet) => context.go(
                        '/main/planet/${planet.id}',
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
