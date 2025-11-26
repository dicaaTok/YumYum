import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFFFF8A65); // Тёплый коралловый
  static const Color secondary = Color(0xFF6C63FF); // Нежный фиолетовый
  static const Color background = Color(0xFFF5F7FA);
  static const Color card = Colors.white;

  static ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: background,
    useMaterial3: true,
    fontFamily: 'Inter',

    colorScheme: ColorScheme.light(
      primary: primary,
      secondary: secondary,
      background: background,
    ),

    /// 🍀 Большие мягкие карточки
    cardTheme: CardThemeData(
      elevation: 0,
      color: card,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
    ),

    /// 🌈 Кнопки
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
    ),

    /// 🔍 Input поля
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      hintStyle: TextStyle(color: Colors.grey.shade500),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
    ),

    /// 🧭 Нижнее меню
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: primary,
      unselectedItemColor: Colors.grey.shade400,
      type: BottomNavigationBarType.fixed,
      elevation: 16,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
    ),
  );
}
