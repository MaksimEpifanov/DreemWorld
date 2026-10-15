import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

/// Аккаунт пользователя.
@freezed
abstract class User with _$User {
  const factory User({
    required String id,
    required String name,
    required int age,
    String? email,
    String? photoUrl,
    String? city,
    String? country,
    String? bio,
    @Default(true) bool isOnline,
    DateTime? lastSeenAt,
    DateTime? createdAt,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
