/// Аккаунт пользователя (кто вошёл в приложение).
///
/// Не путать с `Profile` — это анкета для знакомств. [AppUser] хранит
/// только данные для аутентификации и идентификации текущей сессии.
class AppUser {
  const AppUser({required this.id, required this.email, required this.name});

  final String id;
  final String email;
  final String name;

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
    id: json['id'] as String,
    email: json['email'] as String,
    name: json['name'] as String,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'email': email,
    'name': name,
  };

  AppUser copyWith({String? id, String? email, String? name}) => AppUser(
    id: id ?? this.id,
    email: email ?? this.email,
    name: name ?? this.name,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppUser &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email &&
          name == other.name;

  @override
  int get hashCode => Object.hash(id, email, name);

  @override
  String toString() => 'AppUser(id: $id, email: $email, name: $name)';
}
