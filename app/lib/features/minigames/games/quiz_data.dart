/// Данные викторины: вопросы с вариантами ответа.
class QuizQuestion {
  const QuizQuestion({
    required this.text,
    required this.options,
    required this.correctIndex,
  });

  final String text;
  final List<String> options;
  final int correctIndex;

  bool isCorrect(int index) => index == correctIndex;
}

/// Банк вопросов викторины.
///
/// Вопросы про интересы-планеты и общую эрудицию, чтобы играть было
/// интересно и «по теме» сообщества Dreem World.
const List<QuizQuestion> quizQuestions = <QuizQuestion>[
  QuizQuestion(
    text: 'Столица Японии?',
    options: <String>['Осака', 'Токио', 'Киото', 'Нагоя'],
    correctIndex: 1,
  ),
  QuizQuestion(
    text: 'Какой газ преобладает в атмосфере Земли?',
    options: <String>['Кислород', 'Углекислый газ', 'Азот', 'Водород'],
    correctIndex: 2,
  ),
  QuizQuestion(
    text: 'Сколько струн у классической гитары?',
    options: <String>['5', '6', '7', '4'],
    correctIndex: 1,
  ),
  QuizQuestion(
    text: 'Кто написал «Война и мир»?',
    options: <String>[
      'Фёдор Достоевский',
      'Лев Толстой',
      'Антон Чехов',
      'Иван Тургенев',
    ],
    correctIndex: 1,
  ),
  QuizQuestion(
    text: 'Самая длинная река в мире?',
    options: <String>['Амазонка', 'Нил', 'Янцзы', 'Миссисипи'],
    correctIndex: 1,
  ),
  QuizQuestion(
    text: 'Какая планета ближе всего к Солнцу?',
    options: <String>['Венера', 'Земля', 'Меркурий', 'Марс'],
    correctIndex: 2,
  ),
  QuizQuestion(
    text: 'В каком году человек впервые полетел в космос?',
    options: <String>['1957', '1961', '1969', '1975'],
    correctIndex: 1,
  ),
  QuizQuestion(
    text: 'Что означает аббревиатура HTML?',
    options: <String>[
      'Hyper Text Markup Language',
      'High Tech Modern Language',
      'Hyper Transfer Markup Link',
      'Home Tool Markup Language',
    ],
    correctIndex: 0,
  ),
  QuizQuestion(
    text: 'Сколько цветов у радуги?',
    options: <String>['5', '6', '7', '9'],
    correctIndex: 2,
  ),
  QuizQuestion(
    text: 'Самое крупное животное на планете?',
    options: <String>['Африканский слон', 'Синий кит', 'Жираф', 'Белая акула'],
    correctIndex: 1,
  ),
  QuizQuestion(
    text: 'Какой океан самый большой?',
    options: <String>['Атлантический', 'Индийский', 'Тихий', 'Северный Ледовитый'],
    correctIndex: 2,
  ),
  QuizQuestion(
    text: 'Кто изобрёл телефон?',
    options: <String>[
      'Никола Тесла',
      'Александр Белл',
      'Томас Эдисон',
      'Гульельмо Маркони',
    ],
    correctIndex: 1,
  ),
  QuizQuestion(
    text: 'Какая самая маленькая планета Солнечной системы?',
    options: <String>['Марс', 'Венера', 'Меркурий', 'Плутон'],
    correctIndex: 2,
  ),
  QuizQuestion(
    text: 'Из чего делают бумагу?',
    options: <String>['Из нефти', 'Из древесины', 'Из камня', 'Из металла'],
    correctIndex: 1,
  ),
  QuizQuestion(
    text: 'Сколько минут в сутках?',
    options: <String>['1200', '1440', '1660', '1380'],
    correctIndex: 1,
  ),
  QuizQuestion(
    text: 'Какой вид спорта называют «королевой спорта»?',
    options: <String>['Плавание', 'Лёгкая атлетика', 'Гимнастика', 'Футбол'],
    correctIndex: 1,
  ),
  QuizQuestion(
    text: 'Столица Франции?',
    options: <String>['Лион', 'Марсель', 'Париж', 'Ницца'],
    correctIndex: 2,
  ),
  QuizQuestion(
    text: 'Какой металл жидкий при комнатной температуре?',
    options: <String>['Ртуть', 'Свинец', 'Олово', 'Алюминий'],
    correctIndex: 0,
  ),
  QuizQuestion(
    text: 'Что измеряют в децибелах?',
    options: <String>['Свет', 'Громкость звука', 'Температуру', 'Давление'],
    correctIndex: 1,
  ),
  QuizQuestion(
    text: 'Сколько континентов на Земле?',
    options: <String>['5', '6', '7', '8'],
    correctIndex: 2,
  ),
];
