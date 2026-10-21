import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/app_info.dart';
import '../../core/theme/index.dart';
import '../../core/widgets/index.dart';
import '../../data/providers/auth_providers.dart';
import 'widgets/theme_picker.dart';

/// Экран настроек: выбор темы, параметры приватности,
/// информация о приложении и выход из аккаунта.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _hideOnlineStatus = true;
  bool _showLocation = false;
  bool _personalizedSuggestions = true;
  bool _isLoggingOut = false;

  Future<void> _logout() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Выйти из аккаунта?'),
        content: const Text('Вы сможете войти снова в любой момент.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Выйти'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    setState(() => _isLoggingOut = true);
    await ref.read(authControllerProvider.notifier).logout();
    if (mounted) {
      setState(() => _isLoggingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NeonAppBar(
        title: 'Настройки',
        leading: BackButton(onPressed: () => context.go('/main')),
      ),
      body: SafeArea(
        child: ResponsiveContent(
          child: SingleChildScrollView(
            padding: AppSpacing.page,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const _SectionTitle(
                  icon: Icons.palette_outlined,
                  text: 'Тема оформления',
                ),
                const SizedBox(height: AppSpacing.md),
                const ThemePicker(),
                const SizedBox(height: AppSpacing.xl),
                const _SectionTitle(
                  icon: Icons.lock_outline_rounded,
                  text: 'Приватность',
                ),
                const SizedBox(height: AppSpacing.sm),
                NeonCard(
                  padding: EdgeInsets.zero,
                  child: Material(
                    type: MaterialType.transparency,
                    child: Column(
                      children: <Widget>[
                        _PrivacyToggle(
                          title: 'Скрывать статус «онлайн»',
                          subtitle: 'Другие не увидят, когда вы в сети',
                          value: _hideOnlineStatus,
                          onChanged: (bool value) =>
                              setState(() => _hideOnlineStatus = value),
                        ),
                        const Divider(height: 1),
                        _PrivacyToggle(
                          title: 'Показывать мой город',
                          subtitle: 'Город виден в вашей анкете',
                          value: _showLocation,
                          onChanged: (bool value) =>
                              setState(() => _showLocation = value),
                        ),
                        const Divider(height: 1),
                        _PrivacyToggle(
                          title: 'Персональные рекомендации',
                          subtitle: 'Подбор с учётом ваших интересов',
                          value: _personalizedSuggestions,
                          onChanged: (bool value) => setState(
                            () => _personalizedSuggestions = value,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                const _SectionTitle(
                  icon: Icons.shield_moon_rounded,
                  text: 'Безопасность',
                ),
                const SizedBox(height: AppSpacing.sm),
                NeonCard(
                  padding: EdgeInsets.zero,
                  child: Material(
                    type: MaterialType.transparency,
                    child: ListTile(
                      leading: const Icon(Icons.report_gmailerrorred_rounded),
                      title: const Text('Центр безопасности'),
                      subtitle: const Text(
                        'Правила, мои жалобы и заблокированные',
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => context.go('/safety'),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                const _SectionTitle(
                  icon: Icons.info_outline_rounded,
                  text: 'О приложении',
                ),
                const SizedBox(height: AppSpacing.sm),
                NeonCard(
                  padding: EdgeInsets.zero,
                  child: Material(
                    type: MaterialType.transparency,
                    child: Column(
                      children: <Widget>[
                        ListTile(
                          leading: const Icon(Icons.apps_rounded),
                          title: const Text(AppInfo.name),
                          subtitle: const Text(AppInfo.tagline),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.tag_rounded),
                          title: const Text('Версия'),
                          trailing: Text(
                            AppInfo.version,
                            style: AppTextStyles.caption(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                const _SectionTitle(
                  icon: Icons.logout_rounded,
                  text: 'Аккаунт',
                ),
                const SizedBox(height: AppSpacing.sm),
                NeonCard(
                  color: AppColors.error,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(
                        'Выйти из аккаунта',
                        style: AppTextStyles.title(color: AppColors.error),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Вы сможете войти снова в любой момент.',
                        style: AppTextStyles.caption(),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      NeonButton(
                        label: _isLoggingOut ? 'Выход...' : 'Выйти',
                        icon: Icons.logout_rounded,
                        variant: NeonButtonVariant.outlined,
                        color: AppColors.error,
                        isLoading: _isLoggingOut,
                        onPressed: _isLoggingOut ? null : _logout,
                        expanded: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).colorScheme.primary;
    return Row(
      children: <Widget>[
        GlowContainer(
          color: primary,
          glowRadius: 12,
          glowOpacity: 0.5,
          borderRadius: AppRadius.smAll,
          padding: const EdgeInsets.all(AppSpacing.xs),
          child: Icon(icon, size: 18, color: primary),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(text, style: AppTextStyles.title()),
      ],
    );
  }
}

class _PrivacyToggle extends StatelessWidget {
  const _PrivacyToggle({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return SwitchListTile(
      title: Text(title, style: AppTextStyles.body()),
      subtitle: Text(subtitle, style: AppTextStyles.caption()),
      value: value,
      onChanged: onChanged,
      thumbColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
        if (states.contains(WidgetState.selected)) {
          return scheme.primary;
        }
        return scheme.outline;
      }),
      trackColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
        if (states.contains(WidgetState.selected)) {
          return scheme.primary.withValues(alpha: 0.4);
        }
        return scheme.surfaceContainerHighest;
      }),
      trackOutlineColor: WidgetStateProperty.resolveWith<Color>(
        (Set<WidgetState> states) => scheme.primary.withValues(
          alpha: states.contains(WidgetState.selected) ? 0.7 : 0.3,
        ),
      ),
    );
  }
}
