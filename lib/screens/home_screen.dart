import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yum_yum/screens/recipe_screen.dart';
import 'analyze_dish_screen.dart';
import '../services/hf_service.dart';
import '../services/ai_service.dart';
import '../widgets/recipe_card.dart';
import 'ingredients_screen.dart';
import 'add_recipe_screen.dart';
import 'my_recipes_screen.dart';
import '../widgets/text_recipe_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _image;
  String? _recognizedDish;
  String? _recipe;
  bool _loading = false;

  Future<void> _pickAndAnalyzeImage() async {
    setState(() => _loading = true);

    try {
      final picked = await ImagePicker().pickImage(source: ImageSource.camera);
      if (picked == null) {
        setState(() => _loading = false);
        return;
      }

      _image = File(picked.path);

      final label = await HuggingFaceService.recognizeFood(_image!);
      _recognizedDish = label;

      _recipe = await AIService.getRecipeFromOpenAI(label);
    } catch (e) {
      _recipe = 'Ошибка: $e';
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🍳 Книжка рецептов с ИИ')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_image != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(_image!, height: 200),
                ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.camera_alt),
                label: const Text('Сфотографировать блюдо'),
                onPressed: _pickAndAnalyzeImage,
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.kitchen),
                label: const Text('Что приготовить из моих продуктов'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const IngredientsScreen()),
                  );
                },
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.health_and_safety),
                label: const Text('Анализ полезности блюда'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const AnalyzeDishScreen()),
                  );
                },
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Добавить свой рецепт'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const AddRecipeScreen()),
                  );
                },
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.book),
                label: const Text('Мои рецепты'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const MyRecipesScreen()),
                  );
                },
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.star),
                label: const Text('Рейтинг рецептов'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RatingScreen(recipes: []), // сюда подставим список
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),
              if (_recognizedDish != null)
                Text(
                  'Распознано: $_recognizedDish',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 16),
              if (_recipe != null) TextRecipeCard(recipeText: _recipe!),
            ],
          ),
        ),
      ),
    );
  }
}
