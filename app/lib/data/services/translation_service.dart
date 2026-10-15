/// Абстракция автоперевода сообщений.
///
/// Отдельно от [AiService]: перевод может уходить на другой бэкенд.
abstract interface class TranslationService {
  /// Поддерживаемые языки (коды ISO 639-1).
  List<String> get supportedLanguages;

  /// Язык по умолчанию для автоперевода.
  String get defaultTargetLanguage;

  /// Переводит [text] с [fromLang] на [toLang].
  ///
  /// Если языки совпадают — возвращает исходный текст.
  Future<String> translate(
    String text, {
    required String fromLang,
    required String toLang,
  });
}
