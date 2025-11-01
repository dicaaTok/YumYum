class SuggestedRecipe {
  final String title;
  final String shortDescription;
  final List<String> ingredients; // полные строки ингредиентов
  final List<String> steps;
  final int calories;
  final String difficulty; // "easy", "medium", "hard" или текст
  final int cookTimeMinutes; // пример: 30

  SuggestedRecipe({
    required this.title,
    required this.shortDescription,
    required this.ingredients,
    required this.steps,
    required this.calories,
    required this.difficulty,
    required this.cookTimeMinutes,
  });

  factory SuggestedRecipe.fromMap(Map<String, dynamic> m) {
    return SuggestedRecipe(
      title: m['title']?.toString() ?? 'Без названия',
      shortDescription: m['shortDescription']?.toString() ?? '',
      ingredients: List<String>.from(m['ingredients'] ?? []),
      steps: List<String>.from(m['steps'] ?? []),
      calories: (m['calories'] is int) ? m['calories'] : int.tryParse('${m['calories']}') ?? 0,
      difficulty: m['difficulty']?.toString() ?? 'unknown',
      cookTimeMinutes: (m['cookTimeMinutes'] is int) ? m['cookTimeMinutes'] : int.tryParse('${m['cookTimeMinutes']}') ?? 0,
    );
  }
}
