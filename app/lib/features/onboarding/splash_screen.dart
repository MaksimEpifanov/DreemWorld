import 'package:flutter/material.dart';

import '../../core/theme/index.dart';
import '../../core/widgets/responsive_content.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveContent(
        child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              'Dreem World',
              style: AppTextStyles.display(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Знакомства по совместимости',
              style: AppTextStyles.body(color: AppColors.textSecondary),
            ),
          ],
        ),
        ),
      ),
    );
  }
}
