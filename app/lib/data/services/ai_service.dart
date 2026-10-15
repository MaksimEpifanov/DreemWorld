import '../models/profile.dart';

/// Абстракция ИИ-функций Dreem World.
///
/// Сейчас реализация — [MockAiService]; реальный провайдер
/// подключается без правок UI.
abstract interface class AiService {
  /// Процент совместимости двух профилей (0–100).
  Future<int> computeCompatibility(Profile a, Profile b);

  /// Темы для разговора, построенные на пересечении интересов и целей.
  Future<List<String>> suggestTopics(Profile a, Profile b);

  /// Перевод [text] на язык [targetLang] (код ISO 639-1, напр. `en`).
  Future<String> translate(String text, String targetLang);
}
