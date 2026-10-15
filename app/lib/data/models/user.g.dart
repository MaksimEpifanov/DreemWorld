// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_User _$UserFromJson(Map<String, dynamic> json) => _User(
  id: json['id'] as String,
  name: json['name'] as String,
  age: (json['age'] as num).toInt(),
  email: json['email'] as String?,
  photoUrl: json['photoUrl'] as String?,
  city: json['city'] as String?,
  country: json['country'] as String?,
  bio: json['bio'] as String?,
  isOnline: json['isOnline'] as bool? ?? true,
  lastSeenAt: json['lastSeenAt'] == null
      ? null
      : DateTime.parse(json['lastSeenAt'] as String),
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$UserToJson(_User instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'age': instance.age,
  'email': instance.email,
  'photoUrl': instance.photoUrl,
  'city': instance.city,
  'country': instance.country,
  'bio': instance.bio,
  'isOnline': instance.isOnline,
  'lastSeenAt': instance.lastSeenAt?.toIso8601String(),
  'createdAt': instance.createdAt?.toIso8601String(),
};
