import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dreem_world/core/theme/app_theme.dart';
import 'package:dreem_world/core/widgets/index.dart';

Widget _host(Widget child) {
  return MaterialApp(
    theme: AppTheme.of(AppThemeName.neonViolet),
    home: Scaffold(body: child),
  );
}

void main() {
  testWidgets('AnimatedGradientBackground renders and animates', (tester) async {
    await tester.pumpWidget(
      _host(const AnimatedGradientBackground()),
    );
    expect(find.byType(AnimatedGradientBackground), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('AnimatedGradientBackgroundLayer shows child', (tester) async {
    await tester.pumpWidget(
      _host(
        const AnimatedGradientBackgroundLayer(
          child: Text('content'),
        ),
      ),
    );
    expect(find.text('content'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 500));
  });

  testWidgets('GlassCard renders child', (tester) async {
    await tester.pumpWidget(
      _host(const GlassCard(child: Text('glass'))),
    );
    expect(find.text('glass'), findsOneWidget);
  });

  testWidgets('NeonGradientText renders text', (tester) async {
    await tester.pumpWidget(
      _host(
        const NeonGradientText(
          'Neon',
          gradient: LinearGradient(colors: <Color>[Colors.purple, Colors.pink]),
        ),
      ),
    );
    expect(find.text('Neon'), findsOneWidget);
  });

  testWidgets('AuraAvatar falls back to initial', (tester) async {
    await tester.pumpWidget(
      _host(const AuraAvatar(fallbackText: 'Dreem', size: 48)),
    );
    expect(find.text('D'), findsOneWidget);
  });

  testWidgets('CompatibilityRing animates to value', (tester) async {
    await tester.pumpWidget(
      _host(const CompatibilityRing(percent: 0.75)),
    );
    expect(find.textContaining('%'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 900));
    expect(find.text('75%'), findsOneWidget);
  });

  testWidgets('NeonButton triggers callback', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      _host(
        Center(
          child: NeonButton(
            label: 'Tap',
            onPressed: () => taps++,
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.text('Tap'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(taps, 1);
  });

  testWidgets('NeonCard renders child', (tester) async {
    await tester.pumpWidget(
      _host(const Center(child: NeonCard(child: Text('card')))),
    );
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('card'), findsOneWidget);
  });
}
