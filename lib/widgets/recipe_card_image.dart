import 'package:flutter/material.dart';
import '../models/user_recipe.dart';

class RecipeCardImage extends StatelessWidget {
  final UserRecipe recipe;

  const RecipeCardImage({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    // Если у рецепта бы было поле imagePath — можно показывать локальное фото,
    // иначе грузим картинку из Unsplash по названию блюда.
    final imageUrl = "https://source.unsplash.com/featured/?${Uri.encodeComponent(recipe.title)}";

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Изображение
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(
              imageUrl,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Container(
                  height: 180,
                  child: const Center(child: CircularProgressIndicator()),
                );
              },
              errorBuilder: (context, error, stack) {
                // На случай ошибки загрузки — просто пустой контейнер или placeholder
                return Container(
                  height: 180,
                  color: Colors.grey.shade300,
                  child: const Center(child: Icon(Icons.fastfood_outlined, size: 48, color: Colors.grey)),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              recipe.title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          // Можно добавить описание, рейтинг и другое
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
            child: Text(
              recipe.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Row(
              children: [
                Icon(Icons.star, color: Colors.amber.shade700),
                const SizedBox(width: 6),
                Text("${recipe.rating.toStringAsFixed(1)}/5"),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
