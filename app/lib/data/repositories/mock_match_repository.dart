import 'dart:async';

import 'package:collection/collection.dart';
import 'package:uuid/uuid.dart';

import '../models/match.dart';
import '../models/profile.dart';
import '../services/ai_service.dart';
import '../services/realtime_service.dart';
import 'match_repository.dart';
import 'mock_profile_repository.dart';
import 'profile_repository.dart';

/// Мэтчи в памяти с сид-данными для демо.
class MockMatchRepository implements MatchRepository {
  MockMatchRepository({
    required this.profileRepository,
    required this.aiService,
    this.currentUserId = MockProfileRepository.defaultCurrentUserId,
    this.realtime,
  }) {
    _matches.addAll(seedMatches);
  }

  /// Профили, которые «лайкнули» текущего пользователя.
  static const Set<String> profilesWhoLikeMe = <String>{
    'p_anna',
    'p_leo',
    'p_sofia',
  };

  /// Демо-мэтчи текущего пользователя.
  static const List<Match> seedMatches = <Match>[
    Match(
      id: 'm_anna',
      user1Id: MockProfileRepository.defaultCurrentUserId,
      user2Id: 'p_anna',
      compatibility: 87,
      status: MatchStatus.active,
    ),
    Match(
      id: 'm_leo',
      user1Id: MockProfileRepository.defaultCurrentUserId,
      user2Id: 'p_leo',
      compatibility: 64,
      status: MatchStatus.liked,
    ),
    Match(
      id: 'm_mia',
      user1Id: MockProfileRepository.defaultCurrentUserId,
      user2Id: 'p_mia',
      compatibility: 58,
      status: MatchStatus.passed,
    ),
  ];

  final ProfileRepository profileRepository;
  final AiService aiService;
  final String currentUserId;
  final RealtimeService? realtime;
  final Uuid _uuid = const Uuid();
  final List<Match> _matches = <Match>[];
  final StreamController<List<Match>> _controller =
      StreamController<List<Match>>.broadcast();

  @override
  Future<List<Match>> getMatches({MatchStatus? status}) async {
    if (status == null) {
      return List<Match>.unmodifiable(_matches);
    }
    return List<Match>.unmodifiable(
      _matches.where((Match match) => match.status == status),
    );
  }

  @override
  Stream<List<Match>> watchMatches() async* {
    yield List<Match>.unmodifiable(_matches);
    yield* _controller.stream;
  }

  @override
  Future<Match?> getMatchById(String id) async =>
      _matches.firstWhereOrNull((Match match) => match.id == id);

  @override
  Future<Match> likeProfile(String profileId) async {
    final Match? existing = _matchWith(profileId);
    if (existing != null) {
      if (existing.status == MatchStatus.active ||
          existing.status == MatchStatus.liked) {
        return existing;
      }
      return _replace(
        existing,
        existing.copyWith(
          status: MatchStatus.liked,
          matchedAt: DateTime.now(),
        ),
      );
    }

    final bool mutual = profilesWhoLikeMe.contains(profileId);
    final Match match = Match(
      id: _uuid.v4(),
      user1Id: currentUserId,
      user2Id: profileId,
      compatibility: await _computeCompatibility(profileId),
      status: mutual ? MatchStatus.active : MatchStatus.liked,
      matchedAt: mutual ? DateTime.now() : null,
      createdAt: DateTime.now(),
    );
    _matches.add(match);
    _notify(match);
    return match;
  }

  @override
  Future<void> passProfile(String profileId) async {
    final Match? existing = _matchWith(profileId);
    if (existing != null) {
      _replace(existing, existing.copyWith(status: MatchStatus.passed));
      return;
    }
    final Match match = Match(
      id: _uuid.v4(),
      user1Id: currentUserId,
      user2Id: profileId,
      status: MatchStatus.passed,
      createdAt: DateTime.now(),
    );
    _matches.add(match);
    _notify(match);
  }

  @override
  Future<void> updateMatchStatus(String matchId, MatchStatus status) async {
    final Match? match =
        _matches.firstWhereOrNull((Match item) => item.id == matchId);
    if (match == null) return;
    _replace(match, match.copyWith(status: status));
  }

  Match? _matchWith(String profileId) => _matches.firstWhereOrNull(
        (Match match) =>
            match.otherUserId(currentUserId) == profileId &&
            match.status != MatchStatus.unmatched,
      );

  Match _replace(Match oldMatch, Match newMatch) {
    final int index = _matches.indexOf(oldMatch);
    if (index >= 0) _matches[index] = newMatch;
    _notify(newMatch);
    return newMatch;
  }

  Future<int> _computeCompatibility(String profileId) async {
    final Profile? me = await profileRepository.getCurrentProfile();
    final Profile? other = await profileRepository.getProfileById(profileId);
    if (me == null || other == null) return 0;
    return aiService.computeCompatibility(me, other);
  }

  void _notify(Match match) {
    if (_controller.isClosed) return;
    _controller.add(List<Match>.unmodifiable(_matches));
    realtime?.emit(RealtimeEvent.matchUpdated(match: match));
  }

  @override
  void dispose() {
    _controller.close();
  }
}
