import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/theme/index.dart';
import '../../core/widgets/index.dart';
import 'widgets/neon_logo_text.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Stack(
        children: <Widget>[
          _buildDecorativeCircles(scheme),
          ResponsiveContent(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const NeonLogoText()
                      .animate()
                      .fadeIn(duration: 600.ms, curve: Curves.easeOut)
                      .scale(
                        begin: const Offset(0.8, 0.8),
                        end: const Offset(1, 1),
                        duration: 600.ms,
                        curve: Curves.easeOutBack,
                      ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Знакомства по совместимости',
                    style: AppTextStyles.body(
                      color: AppColors.textSecondary,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 200.ms, duration: 500.ms)
                      .slideY(
                        begin: 0.3,
                        end: 0,
                        duration: 500.ms,
                        curve: Curves.easeOut,
                      ),
                  const SizedBox(height: AppSpacing.xl),
                  _buildPulsingGlow(scheme)
                      .animate()
                      .fadeIn(delay: 400.ms, duration: 400.ms),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPulsingGlow(ColorScheme scheme) {
    return GlowContainer(
      color: scheme.primary,
      glowRadius: 40,
      glowOpacity: 0.4,
      borderRadius: BorderRadius.circular(100),
      child: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: scheme.primary,
        ),
      ),
    ).animate(onPlay: (AnimationController controller) {
      controller.repeat(reverse: true);
    }).scale(
      begin: const Offset(1, 1),
      end: const Offset(1.4, 1.4),
      duration: 1200.ms,
      curve: Curves.easeInOut,
    );
  }

  Widget _buildDecorativeCircles(ColorScheme scheme) {
    return Stack(
      children: <Widget>[
        Positioned(
          top: -80,
          left: -60,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: scheme.primary.withValues(alpha: 0.12),
            ),
          ).animate().fadeIn(duration: 800.ms),
        ),
        Positioned(
          bottom: -100,
          right: -40,
          child: Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: scheme.tertiary.withValues(alpha: 0.1),
            ),
          ).animate(delay: 100.ms).fadeIn(duration: 800.ms),
        ),
        Positioned(
          top: MediaQuery.of(context).size.height * 0.4,
          right: -30,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: scheme.secondary.withValues(alpha: 0.1),
            ),
          ).animate(delay: 200.ms).fadeIn(duration: 800.ms),
        ),
      ],
    );
  }
}
