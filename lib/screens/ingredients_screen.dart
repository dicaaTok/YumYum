import 'package:flutter/material.dart';
import 'package:yum_yum/screens/recipe_from_suggestion_screen.dart';
import '../services/ai_service.dart';
import '../models/suggested_recipe.dart';
import 'recipe_screen.dart'; // можно переиспользовать экран для детального просмотра

class IngredientsScreen extends StatefulWidget {
  const IngredientsScreen({Key? key}) : super(key: key);

  @override
  State<IngredientsScreen> createState() => _IngredientsScreenState();
}

class _IngredientsScreenState extends State<IngredientsScreen> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _equipmentController = TextEditingController();
  bool _loading = false;
  List<SuggestedRecipe>? _suggestions;
  String? _error;

  Future<void> _findRecipes() async {
    setState(() {
      _loading = true;
      _error = null;
      _suggestions = null;
    });

    try {
      final raw = _controller.text.trim();
      if (raw.isEmpty) {
        setState(() {
          _error = 'Введите хотя бы один ингредиент';
          _loading = false;
        });
        return;
      }
      final ingredients = raw.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
      final equipment = _equipmentController.text.trim();

      final results = await AIService.getRecipesByIngredients(
        ingredients: ingredients,
        equipment: equipment,
        maxSuggestions: 4,
      );

      setState(() {
        _suggestions = results;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _equipmentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Что приготовить из того, что есть'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Перечисли через запятую продукты, которые у тебя есть:'),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              minLines: 1,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'например: курица, помидоры, рис, лук',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _equipmentController,
              decoration: const InputDecoration(
                hintText: 'Оборудование (опционально): духовка, сковорода, мультиварка',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _loading ? null : _findRecipes,
              icon: const Icon(Icons.search),
              label: Text(_loading ? 'Идёт поиск...' : 'Подобрать блюда'),
            ),
            const SizedBox(height: 12),
            if (_error != null) Text('Ошибка: $_error', style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 8),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _suggestions == null
                  ? const Center(child: Text('Рецепты появятся здесь'))
                  : ListView.builder(
                itemCount: _suggestions!.length,
                itemBuilder: (context, index) {
                  final r = _suggestions![index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(r.title),
                      subtitle: Text('${r.shortDescription}\n${r.calories} kcal • ${r.difficulty} • ${r.cookTimeMinutes} мин',
                          maxLines: 2, overflow: TextOverflow.ellipsis),
                      isThreeLine: true,
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // можно передавать конвертированный Recipe или новый экран
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) =>
                            RecipeFromSuggestionScreen(suggested: r)));
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
