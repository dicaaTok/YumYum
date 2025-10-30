import 'dart:io';
import 'package:flutter/material.dart';
import '../models/recipe.dart';

class RecipeScreen extends StatelessWidget {
  final Recipe recipe;
  final File? image;
  final String detectedLabel;

  const RecipeScreen({Key? key, required this.recipe, this.image, required this.detectedLabel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (image != null)
              Image.file(image!, width: double.infinity, height: 220, fit: BoxFit.cover),
            const SizedBox(height: 8),
            Text('Распознано как: $detectedLabel', style: const TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 12),
            Row(
              children: [
                Text('Калории: ${recipe.calories} ккал', style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 16),
                Text('Полезность: ${recipe.healthScore}/10', style: const TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Ингредиенты', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...recipe.ingredients.map((i) => ListTile(
              dense: true,
              leading: const Icon(Icons.check_box_outlined),
              title: Text(i),
            )),
            const SizedBox(height: 12),
            const Text('Шаги', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...recipe.steps.asMap().entries.map((e) {
              final idx = e.key + 1;
              final step = e.value;
              return ListTile(
                leading: CircleAvatar(child: Text('$idx')),
                title: Text(step),
              );
            }),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Тут можно добавить: сохранить в Firebase, начать пошаговую подготовку с таймерами и т.д.
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Сохранено в избранные (демо)')));
              },
              child: const Text('Сохранить рецепт'),
            ),
          ],
        ),
      ),
    );
  }
}
