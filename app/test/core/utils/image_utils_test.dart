import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:dreem_world/core/utils/image_utils.dart';

void main() {
  group('image_utils', () {
    test('encode → decode возвращает исходные байты', () {
      final Uint8List bytes = Uint8List.fromList(
        List<int>.generate(256, (int i) => i, growable: false),
      );

      final String dataUri = encodeImageToDataUri(bytes);

      expect(dataUri.startsWith('data:image/jpeg;base64,'), isTrue);
      expect(dataUri, contains(base64Encode(bytes)));

      final Uint8List? decoded = decodeDataUri(dataUri);
      expect(decoded, isNotNull);
      expect(decoded, equals(bytes));
    });

    test('поддерживает произвольный mime-тип', () {
      final Uint8List bytes = Uint8List.fromList(<int>[1, 2, 3]);

      final String dataUri = encodeImageToDataUri(bytes, mime: 'image/png');

      expect(dataUri.startsWith('data:image/png;base64,'), isTrue);
      expect(decodeDataUri(dataUri), equals(bytes));
    });

    test('пустые и некорректные значения возвращают null', () {
      expect(decodeDataUri(null), isNull);
      expect(decodeDataUri(''), isNull);
      expect(decodeDataUri('not-a-data-uri'), isNull);
      expect(decodeDataUri('data:image/jpeg,plain'), isNull);
      expect(decodeDataUri('data:image/jpeg;base64,***'), isNull);
    });
  });
}
