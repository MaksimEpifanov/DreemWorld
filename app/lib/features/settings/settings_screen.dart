import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/app_info.dart';
import '../../core/theme/index.dart';
import '../../core/widgets/index.dart';
import 'widgets/theme_picker.dart';

/// Экран настроек: выбор темы, раздел «Приватность»,
/// «О приложении» и выход из аккаунта.
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
        content: const Text('Вы всегда сможете войти снова.'),
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
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      context.go('/splash');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const NeonAppBar(title: 'Настройки'),
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
                NeonButton(
                  label: _isLoggingOut ? 'Выход...' : 'Выйти',
                  icon: Icons.logout_rounded,
                  variant: NeonButtonVariant.outlined,
                  color: AppColors.error,
                  isLoading: _isLoggingOut,
                  onPressed: _isLoggingOut ? null : _logout,
                  expanded: true,
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
        Icon(icon, size: 20, color: primary),
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
    return SwitchListTile(
      title: Text(title, style: AppTextStyles.body()),
      subtitle: Text(subtitle, style: AppTextStyles.caption()),
      value: value,
      onChanged: onChanged,
    );
  }
}
