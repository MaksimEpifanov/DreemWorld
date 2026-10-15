import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dreem_world/app.dart';
import 'package:dreem_world/core/theme/index.dart';
import 'package:dreem_world/features/settings/widgets/theme_picker.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('Dreem World app renders smoke test',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: DreemWorldApp()));
    await tester.pumpAndSettle();

    expect(find.text('Dreem World'), findsWidgets);
    expect(find.byType(ThemePicker), findsOneWidget);
  });

  testWidgets('ThemePicker shows all 5 themes and switches theme',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: DreemWorldApp()));
    await tester.pumpAndSettle();

    for (final AppThemeName theme in AppThemeName.values) {
      expect(find.text(theme.palette.title), findsOneWidget);
    }

    await tester.tap(find.text('Matrix Green'));
    await tester.pumpAndSettle();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(kThemeModeNameKey), 'matrix_green');
  });
}
