import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/user_recipe.dart';
import '../widgets/recipe_card.dart';

import '../services/hf_service.dart';
import '../services/ai_service.dart';
import '../services/recipe_storage_service.dart';

import '../widgets/recipe_card_image.dart';
import 'ingredients_screen.dart';
import 'add_recipe_screen.dart';
import 'my_recipes_screen.dart';
import 'analyze_dish_screen.dart';
import 'rating_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _image;
  String? _recognizedDish;
  bool _loading = false;

  String _search = "";
  List<UserRecipe> _allRecipes = [];

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  Future<void> _loadRecipes() async {
    final recipes = RecipeStorageService.getAllRecipes();
    setState(() => _allRecipes = recipes);
  }

  Future<void> _pickAndAnalyzeImage() async {
    setState(() => _loading = true);

    try {
      final picked = await ImagePicker().pickImage(source: ImageSource.camera);
      if (picked == null) {
        setState(() => _loading = false);
        return;
      }

      _image = File(picked.path);

      final label = await HFService.recognizeFood(_image!);
      _recognizedDish = label;

      final recipeText = await AIService.getRecipeFromOpenAI(label);

      final newRecipe = UserRecipe(
        title: _recognizedDish ?? "Без названия",
        description: recipeText ?? "",
        ingredients: ["нет данных"],
        steps: ["нет данных"],
      );

      await RecipeStorageService.addRecipe(newRecipe);
      _loadRecipes();

    } catch (e) {
      print("Ошибка: $e");
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _allRecipes
        .where((r) => r.title.toLowerCase().contains(_search.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("🍳 YumYum"),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt_outlined),
            onPressed: _pickAndAnalyzeImage,
          ),

          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Text("🧺 Что приготовить из продуктов"),
                onTap: () {
                  Future.delayed(
                      const Duration(milliseconds: 100),
                          () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const IngredientsScreen())));
                },
              ),

              PopupMenuItem(
                child: const Text("❤️ Анализ блюда"),
                onTap: () {
                  Future.delayed(
                      const Duration(milliseconds: 100),
                          () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const AnalyzeDishScreen())));
                },
              ),

              PopupMenuItem(
                child: const Text("➕ Добавить рецепт"),
                onTap: () {
                  Future.delayed(
                      const Duration(milliseconds: 100),
                          () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const AddRecipeScreen())));
                },
              ),

              PopupMenuItem(
                child: const Text("📘 Мои рецепты"),
                onTap: () {
                  Future.delayed(
                      const Duration(milliseconds: 100),
                          () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const MyRecipesScreen())));
                },
              ),

              PopupMenuItem(
                child: const Text("⭐ Рейтинг рецептов"),
                onTap: () {
                  Future.delayed(
                      const Duration(milliseconds: 100),
                          () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => RatingScreen(
                                recipes: _allRecipes
                                    .map((u) => u.toRecipe())
                                    .toList(),
                              ))));
                },
              ),
            ],
          )
        ],
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Поиск блюда...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade200,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
          ),

          if (_loading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else
            Expanded(
              child: filtered.isEmpty
                  ? const Center(child: Text("Нет рецептов"))
                  : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: filtered.length,
                itemBuilder: (context, i) {
                  final userRecipe = filtered[i];
                  return RecipeCardImage(recipe: userRecipe);
                },
              ),
            )
        ],
      ),
    );
  }
}
