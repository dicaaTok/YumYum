import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../widgets/recipe_card.dart';

class RatingScreen extends StatefulWidget {
  final List<Recipe> recipes;

  const RatingScreen({super.key, required this.recipes});

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  @override
  Widget build(BuildContext context) {
    final recipes = widget.recipes;

    return Scaffold(
      appBar: AppBar(
        title: const Text('⭐ Рейтинг рецептов'),
      ),
      body: recipes.isEmpty
          ? const Center(
        child: Text(
          'Пока нет рецептов для рейтинга',
          style: TextStyle(fontSize: 18),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: recipes.length,
        itemBuilder: (context, index) {
          return RecipeCard(recipe: recipes[index]);
        },
      ),
    );
  }
}
