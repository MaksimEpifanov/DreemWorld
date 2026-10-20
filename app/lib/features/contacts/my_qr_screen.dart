import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/theme/index.dart';
import '../../core/widgets/index.dart';
import '../../data/providers/app_providers.dart';

/// Экран «Мой QR-код»: код для быстрого добавления в контакты.
class MyQrScreen extends ConsumerWidget {
  const MyQrScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String userId = ref.watch(currentUserIdProvider);
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final String payload = 'dreem://user/$userId';

    return Scaffold(
      appBar: NeonAppBar(
        title: 'Мой QR-код',
        leading: BackButton(onPressed: () => context.go('/contacts')),
      ),
      body: SafeArea(
        child: ResponsiveContent(
          child: Center(
            child: SingleChildScrollView(
              padding: AppSpacing.page,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'Покажите код, чтобы вас добавили',
                    style: AppTextStyles.title(),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  GlassCard(
                    child: Column(
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: AppRadius.lgAll,
                          ),
                          child: QrImageView(
                            data: payload,
                            version: QrVersions.auto,
                            size: 220,
                            backgroundColor: AppColors.white,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'Ваш идентификатор',
                          style: AppTextStyles.caption(),
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(userId, style: AppTextStyles.bodyBold()),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  NeonButton(
                    label: 'Поделиться кодом',
                    icon: Icons.share_outlined,
                    color: scheme.secondary,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Ссылка на профиль скопирована'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
