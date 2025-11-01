import 'package:flutter/material.dart';

class TextRecipeCard extends StatelessWidget {
  final String recipeText;

  const TextRecipeCard({super.key, required this.recipeText});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          recipeText,
          style: const TextStyle(fontSize: 16, height: 1.4),
        ),
      ),
    );
  }
}
