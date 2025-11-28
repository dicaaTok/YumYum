class Recipe {
  final String title; // Название блюда
  final String description; // Краткое описание
  final String ingredients; // Список ингредиентов (строкой или списком)
  final String steps; // Шаги приготовления
  final int time; // Время приготовления в минутах
  final String difficulty; // "Легко", "Средне", "Сложно"
  double rating; // Средняя оценка пользователя (1–5)
  final String? imagePath;

  Recipe({
    required this.title,
    required this.description,
    required this.ingredients,
    required this.steps,
    required this.time,
    required this.difficulty,
    this.rating = 0,
    this.imagePath,
  });

  // Метод для преобразования объекта в Map (если нужно сохранять в JSON)
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'ingredients': ingredients,
      'steps': steps,
      'time': time,
      'difficulty': difficulty,
      'rating': rating,
      'imagePath': imagePath,
    };
  }

  // Метод для создания Recipe из Map
  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      ingredients: map['ingredients'] ?? '',
      steps: map['steps'] ?? '',
      time: map['time'] ?? 0,
      difficulty: map['difficulty'] ?? 'Неизвестно',
      rating: (map['rating'] is double)
          ? map['rating']
          : double.tryParse(map['rating']?.toString() ?? '0') ?? 0,
      imagePath: map['imagePath'],
    );
  }
}
