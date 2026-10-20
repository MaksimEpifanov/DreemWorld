import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Контроллер списка контактов текущего пользователя.
///
/// Хранит идентификаторы добавленных контактов (в мок-режиме — в памяти).
class ContactsController extends StateNotifier<List<String>> {
  ContactsController() : super(const <String>[]);

  /// Добавляет контакт по идентификатору участника.
  void add(String profileId) {
    if (profileId.isEmpty || state.contains(profileId)) return;
    state = <String>[...state, profileId];
  }

  /// Удаляет контакт.
  void remove(String profileId) {
    state = state.where((String id) => id != profileId).toList(growable: false);
  }

  /// Был ли уже добавлен этот участник.
  bool contains(String profileId) => state.contains(profileId);
}

/// Провайдер списка контактов.
final StateNotifierProvider<ContactsController, List<String>> contactsProvider =
    StateNotifierProvider<ContactsController, List<String>>(
  (Ref ref) => ContactsController(),
);
