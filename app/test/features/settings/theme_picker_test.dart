import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dreem_world/core/theme/index.dart';
import 'package:dreem_world/features/settings/widgets/theme_picker.dart';

void main() {
  testWidgets('ThemePicker показывает 5 тем и переключает выбор', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues(<String, Object>{});
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.of(AppThemeName.neonViolet),
          home: const Scaffold(
            body: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: ThemePicker(),
            ),
          ),
        ),
      ),
    );

    expect(container.read(themeControllerProvider), AppThemeName.neonViolet);

    for (final AppThemeName theme in AppThemeName.values) {
      expect(find.text(theme.palette.title), findsOneWidget);
    }

    await tester.tap(find.text('Ice Blue'));
    await tester.pumpAndSettle();

    expect(container.read(themeControllerProvider), AppThemeName.iceBlue);
  });
}
