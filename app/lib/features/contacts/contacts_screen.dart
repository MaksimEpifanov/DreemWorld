import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/index.dart';
import '../../core/widgets/index.dart';
import '../../data/models/index.dart';
import '../../data/providers/app_providers.dart';
import 'contacts_controller.dart';

/// Экран контактов: добавление по QR и список знакомых.
class ContactsScreen extends ConsumerWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<String> contactIds = ref.watch(contactsProvider);
    final Map<String, Profile> profiles = <String, Profile>{
      for (final Profile profile
          in ref.watch(discoveryProfilesProvider).asData?.value ??
              const <Profile>[])
        profile.id: profile,
    };
    final List<Profile> contacts = <Profile>[
      for (final String id in contactIds)
        if (profiles[id] != null) profiles[id]!,
    ];

    return Scaffold(
      appBar: const NeonAppBar(title: 'Контакты'),
      body: SafeArea(
        child: ResponsiveContent(
          child: ListView(
            padding: AppSpacing.page,
            children: <Widget>[
              GlassCard(
                child: Column(
                  children: <Widget>[
                    Row(
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
                                'Покажите свой код или отсканируйте чужой.',
                                style: AppTextStyles.caption(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: NeonButton(
                            label: 'Мой QR',
                            icon: Icons.qr_code_rounded,
                            variant: NeonButtonVariant.outlined,
                            onPressed: () => context.go('/contacts/my-qr'),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: NeonButton(
                            label: 'Сканировать',
                            icon: Icons.qr_code_scanner_rounded,
                            onPressed: () => context.go('/contacts/scan'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 360.ms).slideY(begin: 0.08),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: <Widget>[
                  Text('Мои контакты', style: AppTextStyles.title()),
                  const Spacer(),
                  Text(
                    '${contacts.length}',
                    style: AppTextStyles.caption(),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              if (contacts.isEmpty)
                _EmptyContacts()
              else
                for (int i = 0; i < contacts.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: _ContactTile(
                      profile: contacts[i],
                      index: i,
                      onRemove: () =>
                          ref.read(contactsProvider.notifier).remove(
                                contacts[i].id,
                              ),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyContacts extends StatelessWidget {
  const _EmptyContacts();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Column(
        children: <Widget>[
          Icon(
            Icons.people_alt_outlined,
            size: 64,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Пока нет контактов', style: AppTextStyles.title()),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Добавьте знакомых по QR-коду — они появятся здесь.',
            textAlign: TextAlign.center,
            style: AppTextStyles.body(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({
    required this.profile,
    required this.index,
    required this.onRemove,
  });

  final Profile profile;
  final int index;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Row(
        children: <Widget>[
          AuraAvatar(
            photoUrl: profile.photoUrl,
            size: 52,
            fallbackText: profile.name,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(profile.name, style: AppTextStyles.bodyBold()),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  <String>[
                    if ((profile.city ?? '').isNotEmpty) profile.city!,
                    if (profile.interestNames.isNotEmpty)
                      profile.interestNames.take(2).join(', '),
                  ].join(' • '),
                  style: AppTextStyles.caption(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Удалить',
            icon: const Icon(Icons.person_remove_outlined),
            color: AppColors.error,
            onPressed: onRemove,
          ),
        ],
      ),
    )
        .animate(delay: (index * 50).ms)
        .fadeIn(duration: 300.ms)
        .slideX(begin: 0.08, end: 0, curve: Curves.easeOutCubic);
  }
}
