import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dreem_world/core/theme/index.dart';
import 'package:dreem_world/data/models/index.dart';
import 'package:dreem_world/data/models/relationship_status.dart';
import 'package:dreem_world/data/repositories/mock_profile_repository.dart';
import 'package:dreem_world/features/discovery/widgets/user_card.dart';

void main() {
  final Profile anna = MockProfileRepository.seedProfiles[1];

  void sizeViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(1000, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('UserCard рендерит профиль, совместимость и кнопки', (
    WidgetTester tester,
  ) async {
    sizeViewport(tester);

    bool liked = false;
    bool passed = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.of(AppThemeName.cyberPink),
        home: Scaffold(
          body: SingleChildScrollView(
            child: UserCard(
              profile: anna,
              compatibility: 74,
              onLike: () => liked = true,
              onPass: () => passed = true,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Анна'), findsOneWidget);
    expect(find.text('${anna.age}'), findsOneWidget);
    expect(find.text(anna.city!), findsOneWidget);
    expect(find.text('74%'), findsOneWidget);
    expect(find.text('Нравится'), findsOneWidget);
    expect(find.text('Пропустить'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 600));
    await tester.tap(find.text('Нравится'));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.text('Пропустить'));
    await tester.pump(const Duration(milliseconds: 100));

    expect(liked, isTrue);
    expect(passed, isTrue);
  });

  testWidgets('UserCard блокирует кнопки при isBusy', (
    WidgetTester tester,
  ) async {
    sizeViewport(tester);

    bool liked = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.of(AppThemeName.neonViolet),
        home: Scaffold(
          body: SingleChildScrollView(
            child: UserCard(
              profile: anna,
              compatibility: 50,
              isBusy: true,
              onLike: () => liked = true,
            ),
          ),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 600));
    await tester.tap(find.text('Нравится'));
    await tester.pump(const Duration(milliseconds: 100));

    expect(liked, isFalse);
  });

  testWidgets('UserCard показывает статус отношений', (
    WidgetTester tester,
  ) async {
    sizeViewport(tester);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.of(AppThemeName.neonViolet),
        home: Scaffold(
          body: SingleChildScrollView(
            child: UserCard(
              profile: anna,
              compatibility: 60,
              relationshipStatus: RelationshipStatus.activelyLooking,
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 800));

    expect(
      find.text(RelationshipStatus.activelyLooking.label),
      findsOneWidget,
    );
  });
}
