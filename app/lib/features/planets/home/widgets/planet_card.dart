import 'package:flutter/material.dart';

import '../../../../core/theme/index.dart';
import '../../../../core/widgets/index.dart';
import '../../../../data/models/planet.dart';

/// Карточка планеты-сообщества на главном экране.
class PlanetCard extends StatelessWidget {
  const PlanetCard({super.key, required this.planet, this.onTap});

  final Planet planet;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedPress(
      onPressed: onTap,
      child: GlassCard(
        borderColor: planet.primary,
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(child: Center(child: PlanetOrb(planet: planet, size: 96))),
            const SizedBox(height: AppSpacing.sm),
            Text(
              planet.name,
              style: AppTextStyles.title(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              planet.tagline,
              style: AppTextStyles.caption(),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: <Widget>[
                Icon(Icons.people_alt_outlined, size: 14, color: planet.accent),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    '${planet.memberCount} участников',
                    style: AppTextStyles.label(color: planet.accent),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Неоновый «шар» планеты с эмодзи-символом.
class PlanetOrb extends StatelessWidget {
  const PlanetOrb({super.key, required this.planet, this.size = 96});

  final Planet planet;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(-0.4, -0.4),
          radius: 0.9,
          colors: <Color>[
            planet.secondary,
            planet.primary,
            planet.primary.withValues(alpha: 0.55),
          ],
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: planet.primary.withValues(alpha: 0.6),
            blurRadius: size * 0.5,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: planet.secondary.withValues(alpha: 0.35),
            blurRadius: size * 0.8,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(planet.emoji, style: TextStyle(fontSize: size * 0.42)),
    );
  }
}
