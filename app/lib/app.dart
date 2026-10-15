import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/index.dart';
import 'core/widgets/index.dart';
import 'features/settings/widgets/theme_picker.dart';

class DreemWorldApp extends ConsumerWidget {
  const DreemWorldApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppThemeName themeName = ref.watch(themeControllerProvider);

    return MaterialApp(
      title: 'Dreem World',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.of(themeName),
      home: const _HomeScreen(),
    );
  }
}

class _HomeScreen extends StatelessWidget {
  const _HomeScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const NeonAppBar(title: 'Dreem World'),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: AppSpacing.page,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'Dreem World',
                  style: AppTextStyles.display(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Выбери неоновую тему',
                  style: AppTextStyles.body(color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppSpacing.lg),
                NeonCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Темы', style: AppTextStyles.title()),
                      const SizedBox(height: AppSpacing.md),
                      const ThemePicker(),
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
