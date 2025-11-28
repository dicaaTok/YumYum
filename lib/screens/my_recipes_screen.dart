import 'package:flutter/material.dart';
import '../services/recipe_storage_service.dart';
import '../models/user_recipe.dart';
import '../models/recipe.dart';
import '../widgets/recipe_card.dart';

class MyRecipesScreen extends StatefulWidget {
  const MyRecipesScreen({super.key});

  @override
  State<MyRecipesScreen> createState() => _MyRecipesScreenState();
}

class _MyRecipesScreenState extends State<MyRecipesScreen> {
  late List<UserRecipe> userRecipes;

  @override
  void initState() {
    super.initState();
    userRecipes = RecipeStorageService.getAllRecipes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Мои рецепты')),
      body: userRecipes.isEmpty
          ? const Center(child: Text('У вас пока нет сохранённых рецептов'))
          : ListView.builder(
        itemCount: userRecipes.length,
        itemBuilder: (context, index) {
          final userRecipe = userRecipes[index];

          final displayRecipe = Recipe(
            title: userRecipe.title,
            description: userRecipe.description,
            ingredients: userRecipe.ingredients.join(', '),
            steps: userRecipe.steps.join('. '),
            time: " ",
            difficulty: 'Не указано',
            rating: userRecipe.rating,
          );

          return RecipeCard(recipe: displayRecipe);
        },
      ),
    );
  }
}
