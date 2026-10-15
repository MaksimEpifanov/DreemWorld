// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Match _$MatchFromJson(Map<String, dynamic> json) => _Match(
  id: json['id'] as String,
  user1Id: json['user1Id'] as String,
  user2Id: json['user2Id'] as String,
  compatibility: (json['compatibility'] as num?)?.toInt() ?? 0,
  status:
      $enumDecodeNullable(_$MatchStatusEnumMap, json['status']) ??
      MatchStatus.pending,
  matchedAt: json['matchedAt'] == null
      ? null
      : DateTime.parse(json['matchedAt'] as String),
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$MatchToJson(_Match instance) => <String, dynamic>{
  'id': instance.id,
  'user1Id': instance.user1Id,
  'user2Id': instance.user2Id,
  'compatibility': instance.compatibility,
  'status': _$MatchStatusEnumMap[instance.status]!,
  'matchedAt': instance.matchedAt?.toIso8601String(),
  'createdAt': instance.createdAt?.toIso8601String(),
};

const _$MatchStatusEnumMap = {
  MatchStatus.pending: 'pending',
  MatchStatus.liked: 'liked',
  MatchStatus.passed: 'passed',
  MatchStatus.active: 'active',
  MatchStatus.unmatched: 'unmatched',
};
