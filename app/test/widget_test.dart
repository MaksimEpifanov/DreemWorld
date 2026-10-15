import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dreem_world/app.dart';

void main() {
  testWidgets('Dreem World app renders smoke test',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: DreemWorldApp()));

    expect(find.text('Dreem World'), findsOneWidget);
  });
}
