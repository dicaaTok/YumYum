import 'package:flutter/material.dart';
import 'home_screen.dart';             // твой главный экран
import 'my_recipes_screen.dart';      // экран «Мои рецепты»
import 'MyGoal/my_goal_screen.dart';         // экран «Моя цель»
import 'search_screen.dart';          // поиск, если был
import 'profile_screen.dart';         // профиль, если был

class MainNavigation extends StatefulWidget {
  const MainNavigation({Key? key}) : super(key: key);

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    MyRecipesScreen(),
    MyGoalScreen(),
    SearchScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const <NavigationDestination>[
          NavigationDestination(icon: Icon(Icons.home), label: 'Главная'),
          NavigationDestination(icon: Icon(Icons.book), label: 'Мои рецепты'),
          NavigationDestination(icon: Icon(Icons.flag), label: 'Моя цель'),
          NavigationDestination(icon: Icon(Icons.search), label: 'Поиск'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Профиль'),
        ],
      ),
    );
  }
}
