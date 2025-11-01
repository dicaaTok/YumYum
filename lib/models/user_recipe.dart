import 'package:hive/hive.dart';

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

  UserRecipe({
    required this.title,
    required this.description,
    required this.ingredients,
    required this.steps,
    this.rating = 0.0,
  });
}
