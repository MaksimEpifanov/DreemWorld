import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/planet.dart';
import '../../../data/providers/planet_providers.dart';
import '../catalog/widgets/planet_catalog_body.dart';

/// Экран «Другие интересы»: планеты, не вошедшие в избранные по профилю.
class OtherInterestsScreen extends ConsumerWidget {
  const OtherInterestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<Planet> planets = ref.watch(otherPlanetsProvider);
    return PlanetCatalogBody(
      planets: planets,
      title: 'Другие интересы',
      subtitle: 'Планеты, которые не вошли в ваши интересы в профиле.',
    );
  }
}
