import 'package:hive/hive.dart';
import '../models/user_recipe.dart';

class RecipeStorageService {
  static final _box = Hive.box<UserRecipe>('user_recipes');

  static List<UserRecipe> getAllRecipes() {
    return _box.values.toList();
  }

  static Future<void> addRecipe(UserRecipe recipe) async {
    await _box.add(recipe);
  }

  static Future<void> deleteRecipe(int index) async {
    await _box.deleteAt(index);
  }

  static Future<void> updateRecipe(int index, UserRecipe updatedRecipe) async {
    await _box.putAt(index, updatedRecipe);
  }

  static Future<void> clearAll() async {
    await _box.clear();
  }
}
