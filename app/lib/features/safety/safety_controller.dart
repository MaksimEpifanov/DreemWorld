import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/safety.dart';

/// Состояние системы безопасности: поданные жалобы и заблокированные.
class SafetyState {
  const SafetyState({this.reports = const <Report>[], this.blocked = const <BlockedUser>[]});

  final List<Report> reports;
  final List<BlockedUser> blocked;

  bool isBlocked(String userId) =>
      blocked.any((BlockedUser b) => b.userId == userId);

  SafetyState copyWith({List<Report>? reports, List<BlockedUser>? blocked}) {
    return SafetyState(
      reports: reports ?? this.reports,
      blocked: blocked ?? this.blocked,
    );
  }
}

/// Контроллер безопасности: жалобы, блокировки и демо-модерация.
///
/// Логика намеренно «демонстрационная»: жалобы с высокой серьёзностью
/// мгновенно скрывают объект и получают статус «Принята», остальные —
/// «На проверке». Реальный конвейер модераторов подключается позже.
class SafetyController extends StateNotifier<SafetyState> {
  SafetyController() : super(const SafetyState());

  final Random _random = Random();

  /// Подаёт жалобу. Возвращает созданную жалобу с итоговым статусом.
  Report submitReport({
    required String targetId,
    required String targetName,
    required ReportTarget target,
    required ReportReason reason,
    String comment = '',
  }) {
    final bool autoAction = reason.severity >= 3;
    final Report report = Report(
      id: 'r_${DateTime.now().microsecondsSinceEpoch}_${_random.nextInt(999)}',
      targetId: targetId,
      targetName: targetName,
      target: target,
      reason: reason,
      comment: comment,
      createdAt: DateTime.now(),
      status: autoAction ? ReportStatus.actionTaken : ReportStatus.underReview,
      autoHidden: autoAction,
    );
    state = state.copyWith(
      reports: <Report>[report, ...state.reports],
    );
    return report;
  }

  /// Меняет статус жалобы (имитация решения модератора).
  void updateStatus(String reportId, ReportStatus status) {
    state = state.copyWith(
      reports: state.reports
          .map(
            (Report r) => r.id == reportId ? r.copyWith(status: status) : r,
          )
          .toList(growable: false),
    );
  }

  /// Блокирует пользователя.
  void block({
    required String userId,
    required String name,
    String? reason,
  }) {
    if (state.isBlocked(userId)) return;
    state = state.copyWith(
      blocked: <BlockedUser>[
        ...state.blocked,
        BlockedUser(
          userId: userId,
          name: name,
          blockedAt: DateTime.now(),
          reason: reason,
        ),
      ],
    );
  }

  /// Снимает блокировку.
  void unblock(String userId) {
    state = state.copyWith(
      blocked: state.blocked
          .where((BlockedUser b) => b.userId != userId)
          .toList(growable: false),
    );
  }
}

/// Провайдер безопасности.
final StateNotifierProvider<SafetyController, SafetyState> safetyProvider =
    StateNotifierProvider<SafetyController, SafetyState>(
  (Ref ref) => SafetyController(),
);
