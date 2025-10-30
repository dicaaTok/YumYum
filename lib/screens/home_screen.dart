import 'dart:io';
import 'package:flutter/material.dart';
import '../services/image_service.dart';
import '../services/ai_service.dart';
import '../widgets/recipe_card.dart';

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
      // 1. Выбираем фото
      final image = await ImageService.pickImage();
      if (image == null) {
        setState(() => _loading = false);
        return;
      }
      _image = image;

      // 2. Распознаем блюдо
      final label = await ImageService.recognizeFood(image);
      _recognizedDish = label;

      // 3. Получаем рецепт
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
              const SizedBox(height: 20),
              if (_recognizedDish != null)
                Text(
                  'Распознано: $_recognizedDish',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              const SizedBox(height: 20),
              if (_recipe != null) RecipeCard(recipeText: _recipe!),
            ],
          ),
        ),
      ),
    );
  }
}
