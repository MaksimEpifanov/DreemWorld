import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/index.dart';
import '../../../core/widgets/index.dart';
import '../../../data/models/map_spot.dart';
import '../../../data/models/planet.dart';
import '../../../data/providers/planet_providers.dart';
import 'widgets/map_canvas.dart';
import 'widgets/spot_sheet.dart';

/// Карта «внутреннего мира» планеты: отметки мест с тегами, фото и
/// комментариями.
class PlanetMapScreen extends ConsumerStatefulWidget {
  const PlanetMapScreen({super.key, required this.planetId});

  final String planetId;

  @override
  ConsumerState<PlanetMapScreen> createState() => _PlanetMapScreenState();
}

class _PlanetMapScreenState extends ConsumerState<PlanetMapScreen> {
  String? _selectedId;

  @override
  Widget build(BuildContext context) {
    final Planet? planet = ref.watch(planetByIdProvider(widget.planetId));

    if (planet == null) {
      return Scaffold(
        appBar: NeonAppBar(
          title: 'Карта',
          leading: BackButton(
            onPressed: () => context.go('/main/planet/${widget.planetId}'),
          ),
        ),
        body: const Center(child: Text('Планета не найдена')),
      );
    }

    final List<MapSpot> spots = ref.watch(planetMapSpotsProvider(widget.planetId));

    return Scaffold(
      appBar: NeonAppBar(
        title: 'Карта · ${planet.name}',
        leading: BackButton(
          onPressed: () => context.go('/main/planet/${planet.id}'),
        ),
      ),
      body: SafeArea(
        child: ResponsiveContent(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _MapIntro(planet: planet, count: spots.length),
                const SizedBox(height: AppSpacing.sm),
                Expanded(
                  child: MapCanvas(
                    planet: planet,
                    spots: spots,
                    selectedId: _selectedId,
                    onSpotTap: (MapSpot spot) {
                      setState(() => _selectedId = spot.id);
                      showSpotSheet(context, spot: spot, planet: planet);
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: <Widget>[
                    Icon(
                      Icons.info_outline_rounded,
                      size: 16,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        'Нажмите на отметку, чтобы посмотреть фото, '
                        'теги и комментарии.',
                        style: AppTextStyles.caption(),
                      ),
                    ),
                    NeonButton(
                      label: 'Отметить место',
                      icon: Icons.add_location_alt_outlined,
                      color: planet.secondary,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Добавление отметок появится скоро'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Короткая шапка карты: название, число отметок и теги интересов планеты.
class _MapIntro extends StatelessWidget {
  const _MapIntro({required this.planet, required this.count});

  final Planet planet;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(planet.emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                '$count отметок участников',
                style: AppTextStyles.bodyBold(),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: <Widget>[
            for (final String tag in planet.keywords)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: planet.accent.withValues(alpha: 0.12),
                  borderRadius: AppRadius.pillAll,
                  border: Border.all(
                    color: planet.accent.withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  '#$tag',
                  style: AppTextStyles.label(color: planet.accent),
                ),
              ),
          ],
        ),
      ],
    ).animate().fadeIn(duration: 360.ms).slideY(begin: 0.1);
  }
}
