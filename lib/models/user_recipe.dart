import 'package:hive/hive.dart';
import 'package:yum_yum/models/recipe.dart';

part 'user_recipe.g.dart';

@HiveType(typeId: 1)
class UserRecipe extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String description;

  @HiveField(2)
  List<String> ingredients;

  @HiveField(3)
  List<String> steps;

  @HiveField(4)
  double rating;

  @HiveField(5)
  String? imagePath;

  UserRecipe({
    required this.title,
    required this.description,
    required this.ingredients,
    required this.steps,
    this.rating = 0.0,
    this.imagePath,
  });
}

extension UserRecipeMapper on UserRecipe {
  Recipe toRecipe() {
    return Recipe(
      title: title,
      description: description,
      ingredients: ingredients.join(', '),
      steps: steps.join('\n'),
      time: 10,
      difficulty: 'Не указано',
      rating: rating,
      imagePath: imagePath, // <- если поле есть в Recipe
    );
  }
}
