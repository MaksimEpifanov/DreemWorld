import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/index.dart';
import '../../core/widgets/neon_button.dart';
import '../../data/models/index.dart';
import '../../data/providers/app_providers.dart';
import '../../data/repositories/mock_profile_repository.dart';

class ProfileViewEditScreen extends ConsumerStatefulWidget {
  const ProfileViewEditScreen({super.key});

  @override
  ConsumerState<ProfileViewEditScreen> createState() => _ProfileViewEditScreenState();
}

class _ProfileViewEditScreenState extends ConsumerState<ProfileViewEditScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  final List<String> _interestOptions = const <String>[
    'Путешествия',
    'Музыка',
    'Спорт',
    'Чтение',
    'Фильмы',
    'Искусство',
    'Технологии',
    'Еда',
    'Природа',
    'Игры',
  ];

  final Set<String> _selectedInterests = <String>{};
  RelationshipGoal _relationshipGoal = RelationshipGoal.friendship;
  final Set<String> _selectedValues = <String>{};
  final List<String> _valueOptions = const <String>[
    'Честность',
    'Уважение',
    'Доверие',
    'Поддержка',
    'Юмор',
    'Амбициозность',
  ];
  final List<String> _goalOptions = const <String>[
    'Общение',
    'Дружба',
    'Отношения',
    'Семья',
  ];
  final Set<String> _selectedGoals = <String>{};

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profileRepo = ref.read(profileRepositoryProvider);
    final profile = await profileRepo.getCurrentProfile();
    if (mounted && profile != null) {
      _nameController.text = profile.name;
      _ageController.text = profile.age.toString();
      _cityController.text = profile.city;
      _bioController.text = profile.bio ?? '';
      _relationshipGoal = profile.relationshipGoal;
      _selectedGoals.clear();
      _selectedGoals.addAll(profile.goals);
      _selectedValues.clear();
      _selectedValues.addAll(profile.values);
      _selectedInterests.clear();
      for (final interest in profile.interests) {
        if (interest.name.isNotEmpty) {
          _selectedInterests.add(interest.name);
        }
      }
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _cityController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _isSaving = true);

    final profileRepo = ref.read(profileRepositoryProvider);
    final currentUserId = ref.read(currentUserIdProvider);

    final Profile updatedProfile = Profile(
      id: currentUserId,
      name: _nameController.text.trim(),
      age: int.tryParse(_ageController.text.trim()) ?? 18,
      city: _cityController.text.trim(),
      country: 'Россия',
      bio: _bioController.text.trim(),
      interests: _selectedInterests.map((s) {
        switch (s) {
          case 'Путешествия':
            return InterestCatalog.travel;
          case 'Музыка':
            return InterestCatalog.music;
          case 'Спорт':
            return InterestCatalog.sport;
          case 'Чтение':
            return InterestCatalog.books;
          case 'Фильмы':
            return InterestCatalog.cinema;
          case 'Искусство':
            return InterestCatalog.art;
          case 'Технологии':
            return InterestCatalog.tech;
          case 'Еда':
            return InterestCatalog.food;
          case 'Природа':
            return InterestCatalog.nature;
          case 'Игры':
            return InterestCatalog.games;
          default:
            return Interest(
              id: s,
              name: s,
              category: InterestCategory.other,
              icon: 'star',
            );
        }
      }).toList(),
      goals: _selectedGoals.toList(),
      values: _selectedValues.toList(),
      languages: const <String>['ru'],
      relationshipGoal: _relationshipGoal,
    );

    await profileRepo.saveProfile(updatedProfile);

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Профиль')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: AppSpacing.page,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Имя'),
                  validator: (String? value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Введите имя';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _ageController,
                  decoration: const InputDecoration(labelText: 'Возраст'),
                  keyboardType: TextInputType.number,
                  validator: (String? value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Введите возраст';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _cityController,
                  decoration: const InputDecoration(labelText: 'Город'),
                  validator: (String? value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Введите город';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                Text('Интересы', style: AppTextStyles.title()),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _interestOptions.map((String interest) {
                    final bool selected = _selectedInterests.contains(interest);
                    return FilterChip(
                      label: Text(interest),
                      selected: selected,
                      onSelected: (bool value) {
                        setState(() {
                          if (value) {
                            _selectedInterests.add(interest);
                          } else {
                            _selectedInterests.remove(interest);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text('Цель отношений', style: AppTextStyles.title()),
                const SizedBox(height: AppSpacing.sm),
                SegmentedButton<RelationshipGoal>(
                  segments: const <ButtonSegment<RelationshipGoal>>[
                    ButtonSegment<RelationshipGoal>(
                      value: RelationshipGoal.friendship,
                      label: Text('Дружба'),
                    ),
                    ButtonSegment<RelationshipGoal>(
                      value: RelationshipGoal.chat,
                      label: Text('Чат'),
                    ),
                    ButtonSegment<RelationshipGoal>(
                      value: RelationshipGoal.dating,
                      label: Text('Свидания'),
                    ),
                    ButtonSegment<RelationshipGoal>(
                      value: RelationshipGoal.serious,
                      label: Text('Серьезные'),
                    ),
                  ],
                  selected: <RelationshipGoal>{_relationshipGoal},
                  onSelectionChanged: (Set<RelationshipGoal> newSelection) {
                    setState(() {
                      _relationshipGoal = newSelection.first;
                    });
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                Text('Ценности', style: AppTextStyles.title()),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _valueOptions.map((String value) {
                    final bool selected = _selectedValues.contains(value);
                    return FilterChip(
                      label: Text(value),
                      selected: selected,
                      onSelected: (bool valueChip) {
                        setState(() {
                          if (valueChip) {
                            _selectedValues.add(value);
                          } else {
                            _selectedValues.remove(value);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text('Цель', style: AppTextStyles.title()),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _goalOptions.map((String goal) {
                    final bool selected = _selectedGoals.contains(goal);
                    return FilterChip(
                      label: Text(goal),
                      selected: selected,
                      onSelected: (bool value) {
                        setState(() {
                          if (value) {
                            _selectedGoals.add(goal);
                          } else {
                            _selectedGoals.remove(goal);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text('О себе', style: AppTextStyles.title()),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: _bioController,
                  decoration: const InputDecoration(labelText: 'Коротко о себе'),
                  maxLines: 3,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text('Фото-заглушка', style: AppTextStyles.title()),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Center(
                    child: Icon(Icons.add_photo_alternate_outlined, size: 48),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  width: double.infinity,
                  child: NeonButton(
                    onPressed: _isSaving ? null : _save,
                    child: Text(_isSaving ? 'Сохранение...' : 'Сохранить'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
