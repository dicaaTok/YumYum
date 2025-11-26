import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:yum_yum/screens/main_screen.dart';
import 'package:yum_yum/theme/theme.dart';
import 'models/user_recipe.dart';
import 'theme/app_theme.dart' hide AppTheme;
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();


  // ✅ Загружаем .env перед любыми зависимостями
  await dotenv.load(fileName: ".env");

  // ✅ Инициализация Hive
  await Hive.initFlutter();
  Hive.registerAdapter(UserRecipeAdapter());
  await Hive.openBox<UserRecipe>('user_recipes');

  runApp(const YumYumApp());
}

class YumYumApp extends StatelessWidget {
  const YumYumApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YumYum 🍳',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainScreen(),
    );
  }
}
