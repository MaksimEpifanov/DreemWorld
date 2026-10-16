import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dreem_world/features/profile/profile_setup_screen.dart';
import 'package:dreem_world/features/profile/widgets/photo_picker.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('ProfileSetupScreen содержит PhotoPicker', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: ProfileSetupScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(PhotoPicker), findsOneWidget);
    expect(find.text('Галерея'), findsOneWidget);
    expect(find.text('Камера'), findsOneWidget);
  });
}
