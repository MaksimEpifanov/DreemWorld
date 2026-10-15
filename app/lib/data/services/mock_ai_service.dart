import '../models/interest.dart';
import '../models/profile.dart';
import 'ai_service.dart';

/// Детерминированный мок ИИ: работает офлайн, без сети.
///
/// Алгоритм совместимости: пересечение интересов (60%),
/// близость возраста (20%) и общие цели (20%).
class MockAiService implements AiService {
  const MockAiService();

  @override
  Future<int> computeCompatibility(Profile a, Profile b) async {
    final Set<String> aIds = a.interests.map((Interest i) => i.id).toSet();
    final Set<String> bIds = b.interests.map((Interest i) => i.id).toSet();
    final Set<String> shared = aIds.intersection(bIds);
    final Set<String> union = aIds.union(bIds);

    final double interestScore = union.isEmpty
        ? 0.2
        : shared.length / union.length;

    final int ageDiff = (a.age - b.age).abs();
    final double ageScore = ageDiff >= 15 ? 0 : 1 - ageDiff / 15;

    final double goalsScore = _stringOverlap(a.goals, b.goals);

    final double score =
        interestScore * 0.6 + ageScore * 0.2 + goalsScore * 0.2;
    return (score * 100).round().clamp(0, 100).toInt();
  }

  @override
  Future<List<String>> suggestTopics(Profile a, Profile b) async {
    final Set<String> sharedNames = <String>{
      for (final Interest interest in a.interests)
        if (b.interests.any((Interest other) => other.id == interest.id))
          interest.name,
    };

    final List<String> topics = <String>[
      if (sharedNames.isNotEmpty) 'Общие интересы: ${sharedNames.join(', ')}',
      ...sharedNames.map((String name) => 'Что увлекает в «$name»?'),
      if (a.city != null && a.city == b.city)
        'Как вам нравится жить в ${a.city}?',
      'Путешествия: какое место запомнилось больше всего?',
    ];
    return topics.take(5).toList(growable: false);
  }

  @override
  Future<String> translate(String text, String targetLang) async {
    if (text.trim().isEmpty || targetLang.trim().isEmpty) {
      return text;
    }
    // TODO(A7): заменить на реальный переводчик.
    return '[$targetLang] $text';
  }

  double _stringOverlap(List<String> a, List<String> b) {
    if (a.isEmpty || b.isEmpty) return 0.3;
    final Set<String> lowerA = a.map((String s) => s.toLowerCase()).toSet();
    final Set<String> lowerB = b.map((String s) => s.toLowerCase()).toSet();
    final Set<String> union = lowerA.union(lowerB);
    if (union.isEmpty) return 0.3;
    return lowerA.intersection(lowerB).length / union.length;
  }
}
