// lib/services/ai_service.dart
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/user_recipe.dart';

class AIService {
  static final String? _openaiKey = dotenv.env["OPENAI_API_KEY"];
  static final String? _openaiModel = dotenv.env["OPENAI_MODEL"] ?? "gpt-4o-mini";

  static final String? _hfKey = dotenv.env["HUGGINGFACE_API_KEY"];
  static final String? _hfModel = dotenv.env["HUGGINGFACE_MODEL"] ?? "google/vit-base-patch16-224";

  // ==========================================================
  // 1) 🔥 STAY — СТАРЫЕ ФУНКЦИИ (из твоего GitHub)
  // ==========================================================

  /// HuggingFace CLASSIFICATION
  static Future<String> classifyImage(List<int> imageBytes) async {
    final url = Uri.parse("https://api-inference.huggingface.co/models/$_hfModel");

    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $_hfKey",
        "Content-Type": "application/octet-stream",
      },
      body: imageBytes,
    );

    if (response.statusCode != 200) {
      throw Exception("HF Error: ${response.statusCode} — ${response.body}");
    }

    final data = jsonDecode(response.body);
    try {
      return data[0][0]["label"]; // top label
    } catch (_) {
      return "unknown";
    }
  }

  /// Генерация рецепта по ингредиентам
  static Future<String> generateRecipeFromIngredients(String ingredients) async {
    final url = Uri.parse("https://api.openai.com/v1/chat/completions");

    final body = jsonEncode({
      "model": _openaiModel,
      "messages": [
        {"role": "system", "content": "Create recipes from ingredients."},
        {"role": "user", "content": "Create a recipe using: $ingredients"}
      ],
      "temperature": 0.7,
    });

    final resp = await http.post(url,
        headers: {
          "Authorization": "Bearer $_openaiKey",
          "Content-Type": "application/json"
        },
        body: body);

    final json = jsonDecode(resp.body);
    return json["choices"][0]["message"]["content"];
  }

  /// Анализ блюда
  static Future<String> analyzeDish(String text) async {
    final url = Uri.parse("https://api.openai.com/v1/chat/completions");

    final body = jsonEncode({
      "model": _openaiModel,
      "messages": [
        {"role": "system", "content": "Analyze dishes."},
        {"role": "user", "content": text}
      ],
    });

    final resp = await http.post(url,
        headers: {
          "Authorization": "Bearer $_openaiKey",
          "Content-Type": "application/json"
        },
        body: body);

    final json = jsonDecode(resp.body);
    return json["choices"][0]["message"]["content"];
  }

  // ==========================================================
  // 2) 🔥 NEW — НОВАЯ ФУНКЦИЯ: ЧАТ ДЛЯ СТРАНИЦЫ РЕЦЕПТА
  // ==========================================================

  /// Новый умный чат по рецепту 💬🍳
  /// + контекст рецепта
  /// + label от HuggingFace
  /// + время / сложность / рейтинг
  static Future<String> askRecipeChat({
    required UserRecipe recipe,
    required String question,
  }) async {
    if (_openaiKey == null) {
      throw Exception("OPENAI_API_KEY not found in .env");
    }

    // -----------------------------
    // 1) Распознаем фото (если есть URL)
    // -----------------------------
    String imageLabel = "none";

    if (recipe.imageUrl.isNotEmpty) {
      try {
        final img = await http.get(Uri.parse(recipe.imageUrl));
        if (img.statusCode == 200) {
          imageLabel = await classifyImage(img.bodyBytes);
        }
      } catch (_) {
        imageLabel = "unrecognized";
      }
    }

    // -----------------------------
    // 2) Формируем системный промпт
    // -----------------------------
    final system = """
Ты — умный повар-ассистент. Помогаешь пользователю готовить блюда.

Вот информация о рецепте:

Название: ${recipe.title}
Описание: ${recipe.description}

Ингредиенты:
${recipe.ingredients.join(", ")}

Шаги:
${recipe.steps.join("\n")}

Время приготовления: ${recipe.time} минут
Сложность: ${recipe.difficulty}
Рейтинг: ${recipe.rating}

AI-распознавание фото: $imageLabel

Отвечай дружелюбно, чётко, коротко, но по делу.
Если могут быть опасности — предупреди.
""";

    // -----------------------------
    // 3) Отправляем запрос к OpenAI
    // -----------------------------
    final url = Uri.parse("https://api.openai.com/v1/chat/completions");

    final payload = jsonEncode({
      "model": _openaiModel,
      "messages": [
        {"role": "system", "content": system},
        {"role": "user", "content": question}
      ],
      "temperature": 0.7,
      "max_tokens": 350,
    });

    final resp = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $_openaiKey",
        "Content-Type": "application/json",
      },
      body: payload,
    );

    if (resp.statusCode != 200) {
      throw Exception("OpenAI error: ${resp.body}");
    }

    final json = jsonDecode(resp.body);
    return json["choices"][0]["message"]["content"] ?? "Ошибка: пустой ответ.";
  }
}
