import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/router/app_router.dart';
import 'core/theme/index.dart';

class DreemWorldApp extends ConsumerWidget {
  const DreemWorldApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppThemeName themeName = ref.watch(themeControllerProvider);
    final GoRouter router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Dreem World',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.of(themeName),
      routerConfig: router,
    );
  }
}
