import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_recipe.dart';

class MyRecipesScreen extends StatelessWidget {
  const MyRecipesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Мои рецепты')),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<UserRecipe>('user_recipes').listenable(),
        builder: (context, Box<UserRecipe> box, _) {
          if (box.isEmpty) {
            return const Center(child: Text('Пока нет сохранённых рецептов.'));
          }
          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final recipe = box.getAt(index);
              return Card(
                child: ListTile(
                  title: Text(recipe!.title),
                  subtitle: Text(recipe.description),
                  trailing: Text('⭐ ${recipe.rating.toStringAsFixed(1)}'),
                  onTap: () => _showRecipe(context, recipe),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showRecipe(BuildContext context, UserRecipe recipe) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(recipe.title),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Описание: ${recipe.description}'),
            const SizedBox(height: 8),
            Text('Ингредиенты: ${recipe.ingredients.join(', ')}'),
            const SizedBox(height: 8),
            Text('Шаги: ${recipe.steps.join('. ')}'),
            const SizedBox(height: 8),
            Text('Рейтинг: ⭐ ${recipe.rating.toStringAsFixed(1)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }
}
