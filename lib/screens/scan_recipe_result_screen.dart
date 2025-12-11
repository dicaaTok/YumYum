import 'package:flutter/material.dart';
import '../models/user_recipe.dart';
import 'recipe_detail_screen.dart';
import '../services/ai_service.dart';

class ScanRecipeResultScreen extends StatefulWidget {
  final String imagePath;

  const ScanRecipeResultScreen({super.key, required this.imagePath});

  @override
  State<ScanRecipeResultScreen> createState() => _ScanRecipeResultScreenState();
}

class _ScanRecipeResultScreenState extends State<ScanRecipeResultScreen> {
  bool loading = true;
  UserRecipe? recipe;

  @override
  void initState() {
    super.initState();
    _loadRecipe();
  }

  Future<void> _loadRecipe() async {
    final result = await AIService.generateRecipeFromImage(widget.imagePath);

    setState(() {
      recipe = result;
      loading = false;
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => RecipeDetailScreen(recipe: recipe!),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Анализ блюда")),
      body: Center(
        child: loading
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text("Анализируем блюдо...")
          ],
        )
            : const Text("Открываем рецепт..."),
      ),
    );
  }
}
