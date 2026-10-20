/// Правила возрастной безопасности личных чатов.
///
/// Несовершеннолетним запрещены личные переписки со взрослыми (18+):
/// это снижает риск контакта с потенциальными злоумышленниками.
class AgeSafety {
  const AgeSafety._();

  /// Совершеннолетний ли возраст.
  static bool isAdult(int age) => age >= 18;

  /// Несовершеннолетний ли возраст.
  static bool isMinor(int age) => age < 18;

  /// Разрешён ли личный чат между двумя возрастами.
  static bool canChatPrivately({required int myAge, required int otherAge}) {
    if (isMinor(myAge) && isAdult(otherAge)) return false;
    if (isAdult(myAge) && isMinor(otherAge)) return false;
    return true;
  }

  /// Пояснение, почему чат закрыт (или `null`, если он разрешён).
  static String? restrictionReason({required int myAge, required int otherAge}) {
    if (isMinor(myAge) && isAdult(otherAge)) {
      return 'Личные чаты со взрослыми закрыты для вашего возраста. '
          'Так мы защищаем несовершеннолетних.';
    }
    if (isAdult(myAge) && isMinor(otherAge)) {
      return 'Этот пользователь несовершеннолетний — личный чат недоступен. '
          'Общайтесь в общих пространствах по интересам.';
    }
    return null;
  }
}
