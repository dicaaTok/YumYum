import 'package:flutter/material.dart';
import '../models/user_recipe.dart';
import '../screens/recipe_detail_screen.dart';

class RecipeCardImage extends StatelessWidget {
  final UserRecipe recipe;
  final String title;
  final String imageUrl;

  const RecipeCardImage({
    super.key,
    required this.imageUrl,
    required this.recipe,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(
              imageUrl,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 180,
                color: Colors.grey.shade300,
                child: const Icon(Icons.fastfood_outlined, size: 48),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(recipe.title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),

          if (recipe.description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                recipe.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

          const SizedBox(height: 8),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
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
