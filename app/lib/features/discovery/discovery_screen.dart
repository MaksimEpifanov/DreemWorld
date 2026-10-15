import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/index.dart';
import '../../core/widgets/index.dart';
import '../../data/models/index.dart';
import '../../data/providers/app_providers.dart';
import 'widgets/user_card.dart';

/// Экран подбора: карточки кандидатов и эмуляция взаимного мэтча.
class DiscoveryScreen extends ConsumerStatefulWidget {
  const DiscoveryScreen({super.key});

  @override
  ConsumerState<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends ConsumerState<DiscoveryScreen> {
  int _index = 0;
  bool _isBusy = false;

  void _advance() {
    setState(() {
      _index++;
      _isBusy = false;
    });
  }

  void _restart() {
    setState(() {
      _index = 0;
      _isBusy = false;
    });
  }

  Future<void> _like(Profile profile) async {
    if (_isBusy) return;
    setState(() => _isBusy = true);

    final Match match = await ref
        .read(matchRepositoryProvider)
        .likeProfile(profile.id);
    if (!mounted) return;

    final bool mutual = match.isActive;
    setState(() {
      _isBusy = false;
      _index++;
    });

    if (mutual) {
      context.push('/match?userId=${Uri.encodeComponent(profile.id)}');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Симпатия отправлена. ${profile.name} ответит позже.'),
        ),
      );
    }
  }

  Future<void> _pass(Profile profile) async {
    if (_isBusy) return;
    setState(() => _isBusy = true);

    await ref.read(matchRepositoryProvider).passProfile(profile.id);
    if (!mounted) return;
    _advance();
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<Profile>> profilesAsync = ref.watch(
      discoveryProfilesProvider,
    );

    return Scaffold(
      appBar: NeonAppBar(
        title: 'Dreem World',
        actions: <Widget>[
          IconButton(
            tooltip: 'Профиль',
            onPressed: () => context.push('/profile-edit'),
            icon: const Icon(Icons.person_outline_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: ResponsiveContent(
          child: profilesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (Object error, StackTrace stackTrace) => _Message(
            icon: Icons.error_outline_rounded,
            text: 'Не удалось загрузить анкеты',
          ),
          data: (List<Profile> profiles) {
            if (profiles.isEmpty) {
              return const _Message(
                icon: Icons.explore_off_outlined,
                text: 'Пока нет анкет для подбора',
              );
            }
            if (_index >= profiles.length) {
              return _Message(
                icon: Icons.done_all_rounded,
                text: 'Анкеты закончились',
                actionLabel: 'Начать заново',
                onAction: _restart,
              );
            }

            final Profile profile = profiles[_index];
            final int compatibility =
                ref.watch(compatibilityProvider(profile)).asData?.value ?? 0;

            return Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.sm,
                    AppSpacing.md,
                    0,
                  ),
                  child: Row(
                    children: <Widget>[
                      Text(
                        'Анкета ${_index + 1} из ${profiles.length}',
                        style: AppTextStyles.caption(),
                      ),
                      const Spacer(),
                      if (_isBusy)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: AppSpacing.page,
                    child: UserCard(
                      profile: profile,
                      compatibility: compatibility,
                      isBusy: _isBusy,
                      onLike: () => _like(profile),
                      onPass: () => _pass(profile),
                    ),
                  ),
                ),
              ],
            );
          },
          ),
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({
    required this.icon,
    required this.text,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String text;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.page,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              icon,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              text,
              style: AppTextStyles.title(),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...<Widget>[
              const SizedBox(height: AppSpacing.lg),
              NeonButton(label: actionLabel!, onPressed: onAction),
            ],
          ],
        ),
      ),
    );
  }
}
