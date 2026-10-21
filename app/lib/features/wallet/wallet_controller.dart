import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Состояние кошелька пользователя.
class WalletState {
  const WalletState({
    this.balance = 0,
    this.streak = 0,
    this.lastClaimDate,
    this.earnedDate,
    this.earnedToday = 0,
  });

  final int balance;
  final int streak;
  final String? lastClaimDate;

  /// Дата, к которой относятся заработанные за день монеты.
  final String? earnedDate;

  /// Сколько монет заработано в мини-играх за [earnedDate].
  final int earnedToday;

  WalletState copyWith({
    int? balance,
    int? streak,
    String? lastClaimDate,
    String? earnedDate,
    int? earnedToday,
  }) {
    return WalletState(
      balance: balance ?? this.balance,
      streak: streak ?? this.streak,
      lastClaimDate: lastClaimDate ?? this.lastClaimDate,
      earnedDate: earnedDate ?? this.earnedDate,
      earnedToday: earnedToday ?? this.earnedToday,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'balance': balance,
        'streak': streak,
        'lastClaimDate': lastClaimDate,
        'earnedDate': earnedDate,
        'earnedToday': earnedToday,
      };

  factory WalletState.fromJson(Map<String, dynamic> json) {
    return WalletState(
      balance: (json['balance'] as num?)?.toInt() ?? 0,
      streak: (json['streak'] as num?)?.toInt() ?? 0,
      lastClaimDate: json['lastClaimDate'] as String?,
      earnedDate: json['earnedDate'] as String?,
      earnedToday: (json['earnedToday'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Кошелёк внутриигровой валюты: баланс, серия входов, ежедневный бонус.
class WalletController extends StateNotifier<WalletState> {
  WalletController() : super(const WalletState()) {
    _load();
  }

  static const String _storageKey = 'dreem_wallet_v1';

  /// Дневной потолок заработка монет в мини-играх (не считая входа/колеса).
  static const int dailyGameLimit = 100;

  Future<void> _load() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(_storageKey);
    if (raw == null) return;
    try {
      final Map<String, dynamic> json =
          jsonDecode(raw) as Map<String, dynamic>;
      state = WalletState.fromJson(json);
    } catch (_) {
      // Повреждённые данные — начинаем заново.
    }
  }

  Future<void> _persist() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(state.toJson()));
  }

  static String _today() {
    final DateTime now = DateTime.now();
    final String month = now.month.toString().padLeft(2, '0');
    final String day = now.day.toString().padLeft(2, '0');
    return '${now.year}-$month-$day';
  }

  /// Доступен ли ежедневный бонус сегодня.
  bool get canClaimDaily => state.lastClaimDate != _today();

  /// Размер бонуса за сегодня с учётом серии входов.
  int get dailyBonus => 10 + (state.streak.clamp(0, 6) * 2);

  /// Забирает ежедневный бонус за частые входы.
  Future<int> claimDaily() async {
    if (!canClaimDaily) return 0;
    final int reward = dailyBonus;
    state = state.copyWith(
      balance: state.balance + reward,
      streak: state.streak + 1,
      lastClaimDate: _today(),
    );
    await _persist();
    return reward;
  }

  /// Начисляет монеты (например, за победу в мини-игре).
  Future<void> reward(int amount) async {
    if (amount <= 0) return;
    state = state.copyWith(balance: state.balance + amount);
    await _persist();
  }

  /// Сколько монет ещё можно заработать в мини-играх сегодня.
  int get gamesRemaining {
    final int earned = state.earnedDate == _today() ? state.earnedToday : 0;
    final int left = dailyGameLimit - earned;
    return left < 0 ? 0 : left;
  }

  /// Начисляет монеты за мини-игру с учётом дневного потолка.
  ///
  /// Возвращает фактически начисленную сумму (может быть меньше запрошенной
  /// или 0, если дневной лимит исчерпан).
  Future<int> rewardFromGame(int amount) async {
    if (amount <= 0) return 0;
    final int earned = state.earnedDate == _today() ? state.earnedToday : 0;
    final int left = dailyGameLimit - earned;
    if (left <= 0) return 0;
    final int credited = amount < left ? amount : left;
    state = state.copyWith(
      balance: state.balance + credited,
      earnedDate: _today(),
      earnedToday: earned + credited,
    );
    await _persist();
    return credited;
  }

  /// Списывает монеты; возвращает `false`, если баланса не хватает.
  Future<bool> spend(int amount) async {
    if (amount <= 0) return true;
    if (state.balance < amount) return false;
    state = state.copyWith(balance: state.balance - amount);
    await _persist();
    return true;
  }
}

/// Провайдер кошелька.
final StateNotifierProvider<WalletController, WalletState> walletProvider =
    StateNotifierProvider<WalletController, WalletState>(
  (Ref ref) => WalletController(),
);
