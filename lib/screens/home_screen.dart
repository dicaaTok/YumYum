// lib/screens/home_screen.dart
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yum_yum/screens/recipe_detail_screen.dart';

import '../models/user_recipe.dart';
import '../widgets/recipe_card_image.dart';
import '../services/hf_service.dart';
import '../services/ai_service.dart';
import '../services/recipe_storage_service.dart';

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
  bool _loading = false;
  String _search = "";
  List<UserRecipe> _recipes = [];

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  Future<void> _loadRecipes() async {
    final loaded = RecipeStorageService.getAllRecipes();
    setState(() {
      _recipes = loaded.reversed.toList();
    });

  }

  Future<void> _pickAndAnalyzeImage() async {
    setState(() => _loading = true);

    try {
      final picked = await ImagePicker().pickImage(source: ImageSource.camera);
      if (picked == null) {
        setState(() => _loading = false);
        return;
      }

      final file = File(picked.path);

      // 1) распознаём метку блюда через HuggingFace
      final label = await HFService.recognizeFood(file);

      // 2) используем AIService для генерации полного текста рецепта/описания
      String recipeText = "";
      try {
        recipeText = await AIService.getRecipeFromOpenAI(label);
      } catch (e) {
        // если AIService недоступен, используем простую подпись
        recipeText = "Рецепт для $label";
      }

      // 3) сформируем UserRecipe и сохраним
      final newRecipe = UserRecipe(
        title: label,
        description: recipeText,
        ingredients: ["нет данных"],
        steps: ["нет данных"],
        rating: 0.0,
        imagePath: file.path,
      );

      await RecipeStorageService.addRecipe(newRecipe);

// Перезагрузим список
      await _loadRecipes();

// Открываем экран рецепта сразу после фото
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RecipeDetailScreen(recipe: newRecipe),
          ),
        );
        return;
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e')),
        );
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  void _searchFood(String query) {
    setState(() {
      _search = query.trim();
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _search.isEmpty
        ? _recipes
        : _recipes.where((r) => r.title.toLowerCase().contains(_search.toLowerCase())).toList();

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
                      MaterialPageRoute(builder: (_) => const IngredientsScreen()),
                    ),
                  );
                },
              ),
              PopupMenuItem(
                child: const Text("❤️ Анализ блюда"),
                onTap: () {
                  Future.delayed(
                    const Duration(milliseconds: 100),
                        () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AnalyzeDishScreen()),
                    ),
                  );
                },
              ),
              PopupMenuItem(
                child: const Text("➕ Добавить рецепт"),
                onTap: () {
                  Future.delayed(
                    const Duration(milliseconds: 100),
                        () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AddRecipeScreen()),
                    ).then((_) => _loadRecipes()),
                  );
                },
              ),
              PopupMenuItem(
                child: const Text("📘 Мои рецепты"),
                onTap: () {
                  Future.delayed(
                    const Duration(milliseconds: 100),
                        () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => MyRecipesScreen()),
                    ),
                  );
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
                          recipes: RecipeStorageService.getAllRecipes().map((u) => u.toRecipe()).toList(),
                        ),
                      ),
                    ),
                  );
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
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: _searchFood,
            ),
          ),
          if (_loading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (filtered.isEmpty)
            Expanded(
              child: Center(
                child: Text(
                  _recipes.isEmpty
                      ? 'Список рецептов пуст. Нажми на иконку камеры чтобы добавить блюдо.'
                      : 'По запросу "$_search" ничего не найдено.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final recipe = filtered[index];
                  return RecipeCardImage(recipe: recipe);
                },
              ),
            ),
        ],
      ),
    );
  }
}
