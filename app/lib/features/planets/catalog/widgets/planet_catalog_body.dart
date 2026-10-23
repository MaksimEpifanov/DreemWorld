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
      backgroundColor: Colors.transparent,
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
                      AppSpacing.xs,
                      AppSpacing.xs,
                      AppSpacing.md,
                      0,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        IconButton(
                          onPressed: () => context.go('/main'),
                          tooltip: 'Назад',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                          icon: const Icon(Icons.arrow_back_rounded, size: 22),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              NeonGradientText(
                                title,
                                gradient: LinearGradient(
                                  colors: <Color>[
                                    Theme.of(context).colorScheme.primary,
                                    Theme.of(context).colorScheme.secondary,
                                  ],
                                ),
                                style: AppTextStyles.title(),
                              ),
                              Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.pinch_outlined,
                                    size: 12,
                                    color: AppColors.textMuted,
                                  ),
                                  const SizedBox(width: AppSpacing.xxs),
                                  Expanded(
                                    child: Text(
                                      '$subtitle Приблизьте карту и нажмите на планету.',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTextStyles.caption(),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
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
