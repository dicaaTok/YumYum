class Recipe {
  final String title;
  final String description;
  final String ingredients;
  final String steps;

  /// ⬇️ Исправлено: теперь String, а не int
  final String time;

  final String difficulty;
  double rating;
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

  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      ingredients: map['ingredients'] ?? '',
      steps: map['steps'] ?? '',
      time: map['time']?.toString() ?? 'Не указано',
      difficulty: map['difficulty'] ?? 'Не указано',
      rating: double.tryParse(map['rating']?.toString() ?? '0') ?? 0,
      imagePath: map['imagePath'],
    );
  }
}
