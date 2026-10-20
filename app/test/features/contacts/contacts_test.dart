import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:dreem_world/core/theme/index.dart';
import 'package:dreem_world/features/contacts/contacts_controller.dart';
import 'package:dreem_world/features/contacts/contacts_screen.dart';
import 'package:dreem_world/features/contacts/my_qr_screen.dart';

void main() {
  group('Контакты', () {
    test('контроллер добавляет и удаляет контакты без дублей', () {
      final ContactsController controller = ContactsController();

      expect(controller.state, isEmpty);
      controller.add('p_anna');
      controller.add('p_leo');
      controller.add('p_anna'); // дубль игнорируется
      expect(controller.state, <String>['p_anna', 'p_leo']);
      expect(controller.contains('p_leo'), isTrue);

      controller.remove('p_anna');
      expect(controller.state, <String>['p_leo']);
    });

    testWidgets('экран контактов показывает кнопки QR', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.of(AppThemeName.neonViolet),
            home: const ContactsScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Мой QR'), findsOneWidget);
      expect(find.text('Сканировать'), findsOneWidget);
      expect(find.text('Пока нет контактов'), findsOneWidget);
    });

    testWidgets('экран «Мой QR» рендерит QR-код', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.of(AppThemeName.neonViolet),
            home: const MyQrScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(QrImageView), findsOneWidget);
    });
  });
}
