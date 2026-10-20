import 'package:flutter/material.dart';

import '../../../data/models/planet.dart';

/// Природа поверхности планеты — подбирает палитру процедурной текстуры.
enum PlanetSurface {
  ocean,
  desert,
  ice,
  jungle,
  rocky,
  gas,
  lava,
  metallic,
  cloud,
}

/// Определяет тип поверхности по визуальной сцене планеты.
PlanetSurface surfaceForScene(PlanetScene scene) {
  switch (scene) {
    case PlanetScene.fishing:
    case PlanetScene.travel:
    case PlanetScene.finance:
      return PlanetSurface.ocean;
    case PlanetScene.cars:
    case PlanetScene.sports:
    case PlanetScene.selfDevelopment:
      return PlanetSurface.desert;
    case PlanetScene.books:
    case PlanetScene.reading:
    case PlanetScene.psychology:
      return PlanetSurface.cloud;
    case PlanetScene.nature:
    case PlanetScene.gardening:
    case PlanetScene.volunteering:
      return PlanetSurface.jungle;
    case PlanetScene.music:
    case PlanetScene.art:
    case PlanetScene.esoteric:
      return PlanetSurface.gas;
    case PlanetScene.technology:
    case PlanetScene.gaming:
    case PlanetScene.collecting:
      return PlanetSurface.metallic;
    case PlanetScene.cinema:
    case PlanetScene.food:
    case PlanetScene.animals:
      return PlanetSurface.lava;
    case PlanetScene.other:
    case PlanetScene.space:
      return PlanetSurface.rocky;
  }
}

/// Палитра поверхности: базовый, светлый и тёмный оттенки.
class SurfacePalette {
  const SurfacePalette(this.base, this.light, this.dark);

  final Color base;
  final Color light;
  final Color dark;
}

/// Строит палитру поверхности из цветов планеты и её сцены.
SurfacePalette paletteFor(Planet planet) {
  final PlanetSurface surface = surfaceForScene(planet.scene);
  switch (surface) {
    case PlanetSurface.ocean:
      return SurfacePalette(
        Color.lerp(planet.primary, const Color(0xFF0B3D91), 0.55)!,
        Color.lerp(planet.secondary, const Color(0xFF7FD8FF), 0.5)!,
        Color.lerp(planet.primary, Colors.black, 0.55)!,
      );
    case PlanetSurface.desert:
      return SurfacePalette(
        Color.lerp(planet.primary, const Color(0xFFC8944A), 0.5)!,
        Color.lerp(planet.secondary, const Color(0xFFF2D9A0), 0.5)!,
        Color.lerp(planet.primary, Colors.black, 0.5)!,
      );
    case PlanetSurface.ice:
      return SurfacePalette(
        Color.lerp(planet.primary, const Color(0xFFBFE6FF), 0.6)!,
        const Color(0xFFEAF6FF),
        Color.lerp(planet.primary, const Color(0xFF4A7DA6), 0.4)!,
      );
    case PlanetSurface.jungle:
      return SurfacePalette(
        Color.lerp(planet.primary, const Color(0xFF2E7D32), 0.55)!,
        Color.lerp(planet.secondary, const Color(0xFFC7F0A0), 0.5)!,
        Color.lerp(planet.primary, Colors.black, 0.5)!,
      );
    case PlanetSurface.rocky:
      return SurfacePalette(
        Color.lerp(planet.primary, const Color(0xFF8D8D93), 0.45)!,
        Color.lerp(planet.secondary, const Color(0xFFD9D2C4), 0.4)!,
        Color.lerp(planet.primary, Colors.black, 0.6)!,
      );
    case PlanetSurface.gas:
      return SurfacePalette(
        planet.primary,
        Color.lerp(planet.secondary, Colors.white, 0.35)!,
        Color.lerp(planet.primary, Colors.black, 0.45)!,
      );
    case PlanetSurface.lava:
      return SurfacePalette(
        Color.lerp(planet.primary, const Color(0xFF8B2A0F), 0.5)!,
        Color.lerp(planet.secondary, const Color(0xFFFFB05A), 0.5)!,
        Color.lerp(planet.primary, Colors.black, 0.6)!,
      );
    case PlanetSurface.metallic:
      return SurfacePalette(
        Color.lerp(planet.primary, const Color(0xFF6E7B8B), 0.5)!,
        Color.lerp(planet.secondary, const Color(0xFFDCE6F2), 0.45)!,
        Color.lerp(planet.primary, Colors.black, 0.55)!,
      );
    case PlanetSurface.cloud:
      return SurfacePalette(
        Color.lerp(planet.primary, const Color(0xFFCBA6F7), 0.45)!,
        Color.lerp(planet.secondary, Colors.white, 0.45)!,
        Color.lerp(planet.primary, Colors.black, 0.45)!,
      );
  }
}

/// Путь к PNG-ассету планеты (`assets/planets/<id>.png`).
///
/// Файл может отсутствовать — тогда `Image.asset` откатывается на
/// процедурную сферу через `errorBuilder`.
String planetAssetPath(Planet planet) => 'assets/planets/${planet.id}.png';

/// Путь к PNG-ассету солнца.
const String sunAssetPath = 'assets/space/sun.png';
