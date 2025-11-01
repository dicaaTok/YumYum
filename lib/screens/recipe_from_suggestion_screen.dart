import 'package:flutter/material.dart';
import '../models/suggested_recipe.dart';

class RecipeFromSuggestionScreen extends StatelessWidget {
  final SuggestedRecipe suggested;

  const RecipeFromSuggestionScreen({Key? key, required this.suggested}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(suggested.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(suggested.shortDescription, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Row(
              children: [
                Text('Калории: ${suggested.calories} ккал'),
                const SizedBox(width: 12),
                Text('Сложность: ${suggested.difficulty}'),
                const SizedBox(width: 12),
                Text('Время: ${suggested.cookTimeMinutes} мин'),
              ],
            ),
            const SizedBox(height: 12),
            const Text('Ингредиенты', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            ...suggested.ingredients.map((i) => ListTile(
              leading: const Icon(Icons.check_box_outlined),
              title: Text(i),
            )),
            const SizedBox(height: 12),
            const Text('Шаги', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            ...suggested.steps.asMap().entries.map((e) {
              final idx = e.key + 1;
              return ListTile(
                leading: CircleAvatar(child: Text('$idx')),
                title: Text(e.value),
              );
            }),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Placeholder: можно сохранить рецепт в "Мои рецепты" (Hive/Firebase)
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Сохранено (демо)')));
              },
              child: const Text('Сохранить рецепт'),
            ),
          ],
        ),
      ),
    );
  }
}
