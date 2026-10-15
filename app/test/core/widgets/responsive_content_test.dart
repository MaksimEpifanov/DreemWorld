import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dreem_world/core/widgets/index.dart';

void main() {
  testWidgets('ResponsiveContent ограничивает ширину на широком экране', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ResponsiveContent(
            child: SizedBox(key: Key('content'), height: 100, width: 2000),
          ),
        ),
      ),
    );

    final Size size = tester.getSize(find.byKey(const Key('content')));
    expect(
      size.width,
      closeTo(ResponsiveContent.kResponsiveMaxWidth, 0.5),
    );
  });

  testWidgets('ResponsiveContent не ограничивает ширину на узком экране', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ResponsiveContent(
            child: SizedBox(key: Key('content'), height: 100, width: 2000),
          ),
        ),
      ),
    );

    final Size size = tester.getSize(find.byKey(const Key('content')));
    expect(size.width, 400);
  });
}
