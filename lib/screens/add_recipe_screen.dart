import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/user_recipe.dart';

class AddRecipeScreen extends StatefulWidget {
  const AddRecipeScreen({super.key});

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _stepsController = TextEditingController();

  Future<void> _saveRecipe() async {
    final box = Hive.box<UserRecipe>('user_recipes');
    final recipe = UserRecipe(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      ingredients: _ingredientsController.text.split(',').map((e) => e.trim()).toList(),
      steps: _stepsController.text.split('.').map((e) => e.trim()).toList(),
    );
    await box.add(recipe);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Добавить свой рецепт')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Название блюда'),
              ),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Описание'),
              ),
              TextField(
                controller: _ingredientsController,
                decoration: const InputDecoration(labelText: 'Ингредиенты (через запятую)'),
              ),
              TextField(
                controller: _stepsController,
                decoration: const InputDecoration(labelText: 'Шаги (через точку)'),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _saveRecipe,
                icon: const Icon(Icons.save),
                label: const Text('Сохранить рецепт'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
