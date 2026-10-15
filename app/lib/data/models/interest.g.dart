// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'interest.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Interest _$InterestFromJson(Map<String, dynamic> json) => _Interest(
  id: json['id'] as String,
  name: json['name'] as String,
  emoji: json['emoji'] as String?,
  category:
      $enumDecodeNullable(_$InterestCategoryEnumMap, json['category']) ??
      InterestCategory.other,
);

Map<String, dynamic> _$InterestToJson(_Interest instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'emoji': instance.emoji,
  'category': _$InterestCategoryEnumMap[instance.category]!,
};

const _$InterestCategoryEnumMap = {
  InterestCategory.music: 'music',
  InterestCategory.sport: 'sport',
  InterestCategory.travel: 'travel',
  InterestCategory.food: 'food',
  InterestCategory.art: 'art',
  InterestCategory.tech: 'tech',
  InterestCategory.science: 'science',
  InterestCategory.games: 'games',
  InterestCategory.cinema: 'cinema',
  InterestCategory.books: 'books',
  InterestCategory.nature: 'nature',
  InterestCategory.fashion: 'fashion',
  InterestCategory.fitness: 'fitness',
  InterestCategory.languages: 'languages',
  InterestCategory.other: 'other',
};
