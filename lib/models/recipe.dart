class Recipe {
  final String title;
  final List<String> ingredients;
  final List<String> steps;
  final int calories;
  final double healthScore; // 0..10

  Recipe({
    required this.title,
    required this.ingredients,
    required this.steps,
    required this.calories,
    required this.healthScore,
  });

  factory Recipe.fromMap(Map<String, dynamic> m) {
    return Recipe(
      title: m['title'] ?? 'Без названия',
      ingredients: List<String>.from(m['ingredients'] ?? []),
      steps: List<String>.from(m['steps'] ?? []),
      calories: (m['calories'] is int) ? m['calories'] : int.tryParse('${m['calories']}') ?? 0,
      healthScore: (m['healthScore'] is num) ? (m['healthScore'] as num).toDouble() : double.tryParse('${m['healthScore']}') ?? 0.0,
    );
  }
}
