import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/planet.dart';
import '../../../data/providers/planet_providers.dart';
import 'widgets/planet_catalog_body.dart';

/// Экран «Все планеты»: полный каталог сообществ по интересам.
class PlanetsCatalogScreen extends ConsumerWidget {
  const PlanetsCatalogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<Planet> planets = ref.watch(planetsProvider);
    return PlanetCatalogBody(
      planets: planets,
      title: 'Все планеты',
      subtitle: 'Выберите планету — и загляните в её мир.',
    );
  }
}
