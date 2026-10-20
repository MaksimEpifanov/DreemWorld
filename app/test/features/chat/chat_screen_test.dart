import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dreem_world/core/theme/index.dart';
import 'package:dreem_world/features/chat/chat_screen.dart';
import 'package:dreem_world/features/chat/conversations_list_screen.dart';

void main() {
  Future<void> pumpChat(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.of(AppThemeName.neonViolet),
          home: const ChatScreen(conversationId: 'c_anna'),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('ChatScreen рендерит сообщения и поле ввода', (
    WidgetTester tester,
  ) async {
    await pumpChat(tester);

    expect(find.byType(TextField), findsOneWidget);
    expect(find.byIcon(Icons.flag_outlined), findsOneWidget);
    expect(find.text('Введите сообщение...'), findsOneWidget);
    expect(find.textContaining('Привет!'), findsOneWidget);
    expect(find.textContaining('Спасибо!'), findsOneWidget);
  });

  testWidgets('ChatScreen отправляет новое сообщение', (
    WidgetTester tester,
  ) async {
    await pumpChat(tester);

    const String message = 'Привет из теста';
    await tester.enterText(find.byType(TextField), message);
    await tester.tap(find.byIcon(Icons.send_rounded));
    await tester.pumpAndSettle();

    expect(find.text(message), findsOneWidget);
  });

  testWidgets('ChatScreen показывает заблокированный видеовызов', (
    WidgetTester tester,
  ) async {
    await pumpChat(tester);

    expect(find.byIcon(Icons.videocam_outlined), findsOneWidget);
    await tester.tap(find.byIcon(Icons.videocam_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Видеозвонки закрыты'), findsOneWidget);
  });

  testWidgets('список чатов показывает три подвкладки', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.of(AppThemeName.neonViolet),
          home: const ConversationsListScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Все'), findsOneWidget);
    expect(find.text('По интересам'), findsOneWidget);
    expect(find.text('Непрочитанные'), findsOneWidget);
  });
}
