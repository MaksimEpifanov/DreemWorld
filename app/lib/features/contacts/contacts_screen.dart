import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/theme/index.dart';
import '../../core/widgets/index.dart';

/// Экран контактов: люди, с которыми вы уже знакомы.
class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const NeonAppBar(title: 'Контакты'),
      body: SafeArea(
        child: ResponsiveContent(
          child: Padding(
            padding: AppSpacing.page,
            child: Column(
              children: <Widget>[
                GlassCard(
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.qr_code_2_rounded,
                        size: 40,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Добавить по QR-коду',
                              style: AppTextStyles.title(),
                            ),
                            const SizedBox(height: AppSpacing.xxs),
                            Text(
                              'Наведите камеру на код друга, чтобы добавить его.',
                              style: AppTextStyles.caption(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      NeonButton(
                        label: 'QR',
                        color: Theme.of(context).colorScheme.secondary,
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Сканер QR-кодов появится скоро'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 360.ms).slideY(begin: 0.08),
                const SizedBox(height: AppSpacing.lg),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.people_alt_outlined,
                        size: 64,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Пока нет контактов',
                        style: AppTextStyles.title(),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Добавляйте людей из планет и подбора — они появятся здесь.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.body(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
