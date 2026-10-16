import 'dart:convert';
import 'dart:typed_data';

/// Кодирует байты изображения в data URI (`data:image/jpeg;base64,...`).
///
/// Используется, чтобы хранить выбранное фото прямо в [String]
/// (`Profile.photoUrl`) — приемлемо для мок-репозитория.
String encodeImageToDataUri(Uint8List bytes, {String mime = 'image/jpeg'}) {
  return 'data:$mime;base64,${base64Encode(bytes)}';
}

/// Декодирует data URI обратно в байты; `null`/пустая/битая строка → `null`.
Uint8List? decodeDataUri(String? dataUri) {
  if (dataUri == null || dataUri.isEmpty) return null;
  if (!dataUri.startsWith('data:')) return null;

  final int comma = dataUri.indexOf(',');
  if (comma == -1) return null;

  final String metadata = dataUri.substring('data:'.length, comma);
  if (!metadata.contains(';base64')) return null;

  try {
    return base64Decode(dataUri.substring(comma + 1));
  } on FormatException {
    return null;
  }
}
