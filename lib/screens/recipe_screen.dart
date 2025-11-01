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
  String _sortType = 'rating';

  List<Recipe> get sortedRecipes {
    List<Recipe> sorted = [...widget.recipes];
    if (_sortType == 'rating') {
      sorted.sort((a, b) => b.rating.compareTo(a.rating));
    } else if (_sortType == 'time') {
      sorted.sort((a, b) => a.time.compareTo(b.time));
    } else if (_sortType == 'difficulty') {
      sorted.sort((a, b) => a.difficulty.compareTo(b.difficulty));
    }
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('⭐ Рейтинг рецептов')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: DropdownButton<String>(
              value: _sortType,
              items: const [
                DropdownMenuItem(value: 'rating', child: Text('По рейтингу')),
                DropdownMenuItem(value: 'time', child: Text('По времени')),
                DropdownMenuItem(
                    value: 'difficulty', child: Text('По сложности')),
              ],
              onChanged: (v) => setState(() => _sortType = v!),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: sortedRecipes.length,
              itemBuilder: (context, i) =>
                  RecipeCard(recipe: sortedRecipes[i]),
            ),
          ),
        ],
      ),
    );
  }
}
