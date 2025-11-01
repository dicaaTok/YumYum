import 'package:flutter/material.dart';
import '../models/recipe.dart';

class RecipeCard extends StatefulWidget {
  final Recipe recipe;

  const RecipeCard({super.key, required this.recipe});

  @override
  State<RecipeCard> createState() => _RecipeCardState();
}

class _RecipeCardState extends State<RecipeCard> {
  void _updateRating(double newRating) {
    setState(() {
      widget.recipe.rating = newRating;
    });
  }

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(recipe.title,
                style:
                const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Время: ${recipe.time} мин • Сложность: ${recipe.difficulty}'),
            const SizedBox(height: 8),
            Text(recipe.description),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Рейтинг: ', style: TextStyle(fontSize: 16)),
                for (int i = 1; i <= 5; i++)
                  IconButton(
                    icon: Icon(
                      i <= recipe.rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                    ),
                    onPressed: () => _updateRating(i.toDouble()),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
