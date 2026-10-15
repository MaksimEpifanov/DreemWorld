import '../models/match.dart';

/// Мэтчи: взаимные и односторонние симпатии.
abstract interface class MatchRepository {
  /// Список мэтчей, опционально отфильтрованный по статусу.
  Future<List<Match>> getMatches({MatchStatus? status});

  /// Поток мэтчей: первый элемент — текущее состояние.
  Stream<List<Match>> watchMatches();

  /// Мэтч по идентификатору.
  Future<Match?> getMatchById(String id);

  /// Лайк профилю: при взаимности статус становится [MatchStatus.active].
  Future<Match> likeProfile(String profileId);

  /// Пропуск профиля.
  Future<void> passProfile(String profileId);

  /// Смена статуса мэтча.
  Future<void> updateMatchStatus(String matchId, MatchStatus status);

  /// Освобождение ресурсов (потоки).
  void dispose();
}
