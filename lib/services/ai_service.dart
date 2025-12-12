import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/suggested_recipe.dart';
import '../models/user_recipe.dart';

class AIService {
  static const _endpoint = 'https://api.openai.com/v1/chat/completions';
  static const _model = 'gpt-4o-mini';

  /// 🍳 Генерация рецепта по названию блюда
  static Future<String> getRecipeFromOpenAI(String dishName) async {
    final apiKey = dotenv.env['OPENAI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('OPENAI_API_KEY не задан в .env');
    }

    final body = json.encode({
      'model': _model,
      'messages': [
        {
          'role': 'system',
          'content': 'Ты — умный и дружелюбный кулинарный помощник.'
        },
        {
          'role': 'user',
          'content':
          'Как приготовить "$dishName"? Укажи ингредиенты, шаги, калорийность и полезность блюда.'
        }
      ],
      'max_tokens': 700,
      'temperature': 0.6,
    });

    final res = await http.post(
      Uri.parse(_endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: body,
    );

    if (res.statusCode != 200) {
      throw Exception('OpenAI API error: ${res.statusCode} ${res.body}');
    }

    final map = json.decode(res.body);
    final content = map['choices']?[0]?['message']?['content'];
    if (content == null || content.isEmpty) {
      throw Exception('Пустой ответ от OpenAI');
    }

    return content.trim();
  }

  /// 📊 Анализ состава и полезности блюда
  static Future<Map<String, dynamic>> analyzeDish(String dishDescription) async {
    final apiKey = dotenv.env['OPENAI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('OPENAI_API_KEY не задан в .env');
    }

    final body = json.encode({
      'model': _model,
      'messages': [
        {
          'role': 'system',
          'content':
          'Ты — эксперт по питанию. Анализируй блюда и возвращай JSON с калориями, белками, жирами, углеводами и оценкой полезности.'
        },
        {
          'role': 'user',
          'content':
          'Проанализируй блюдо: $dishDescription. Верни JSON: {"calories": число, "proteins": число, "fats": число, "carbs": число, "healthScore": число от 0 до 10, "advice": "совет"}'
        }
      ],
      'max_tokens': 400,
    });

    final res = await http.post(
      Uri.parse(_endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: body,
    );

    if (res.statusCode != 200) {
      throw Exception('OpenAI API error: ${res.statusCode} ${res.body}');
    }

    final map = json.decode(res.body);
    final content = map['choices']?[0]?['message']?['content'];
    if (content == null || content.isEmpty) {
      throw Exception('Пустой ответ от OpenAI');
    }

    try {
      return Map<String, dynamic>.from(json.decode(content));
    } catch (_) {
      return {'advice': content};
    }
  }

  /// 🍽️ Подбор рецептов по ингредиентам
  static Future<List<SuggestedRecipe>> getRecipesByIngredients({
    required List<String> ingredients,
    String equipment = '',
    int maxSuggestions = 4,
  }) async {
    final apiKey = dotenv.env['OPENAI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('OPENAI_API_KEY не задан в .env');
    }

    final prompt = '''
Пользователь указал ингредиенты: ${ingredients.join(', ')}.
Предложи до $maxSuggestions блюд в JSON-формате:
[
  {
    "title": "",
    "shortDescription": "",
    "ingredients": [],
    "steps": [],
    "calories": 0,
    "difficulty": "easy|medium|hard",
    "cookTimeMinutes": 0
  }
]
''' ;

    final body = json.encode({
      'model': _model,
      'messages': [
        {'role': 'system', 'content': 'Ты — кулинарный ассистент, возвращай только JSON.'},
        {'role': 'user', 'content': prompt},
      ],
      'max_tokens': 800,
      'temperature': 0.4,
    });

    final res = await http.post(
      Uri.parse(_endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: body,
    );

    if (res.statusCode != 200) {
      throw Exception('Ошибка OpenAI: ${res.statusCode} ${res.body}');
    }

    final map = json.decode(res.body);
    final content = map['choices']?[0]?['message']?['content'];
    if (content == null || content.isEmpty) {
      throw Exception('Пустой ответ от OpenAI');
    }

    final jsonString = _extractJson(content);
    final parsed = json.decode(jsonString);

    if (parsed is List) {
      return parsed.map((e) => SuggestedRecipe.fromMap(e)).toList();
    } else {
      throw Exception('Неверная структура JSON от OpenAI');
    }
  }
  /// 💬 Ответы на вопросы по конкретному рецепту
  static Future<String> askRecipeQuestion({
    required dynamic recipe,
    required String question,
  }) async {
    final apiKey = dotenv.env['OPENAI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('OPENAI_API_KEY не задан в .env');
    }

    final recipeContext = '''
Название: ${recipe.title}
Описание: ${recipe.description}
Ингредиенты: ${recipe.ingredients.join(", ")}
Шаги приготовления: ${recipe.steps.join(". ")}
Время приготовления: ${recipe.time} минут
Сложность: ${recipe.difficulty}
''';

    final body = json.encode({
      'model': _model,
      'messages': [
        {
          'role': 'system',
          'content': '''
Ты — умный ИИ-повар. Ты отвечаешь на вопросы пользователя строго в контексте рецепта.
Делай ответы короткими, понятными, с конкретными советами.
          '''
        },
        {
          'role': 'user',
          'content':
          'Вот данные рецепта:\n$recipeContext\n\nВопрос: $question'
        }
      ],
      'max_tokens': 500,
      'temperature': 0.5,
    });

    final res = await http.post(
      Uri.parse(_endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: body,
    );

    if (res.statusCode != 200) {
      throw Exception('OpenAI error: ${res.statusCode}');
    }

    final map = json.decode(res.body);
    final content = map['choices']?[0]?['message']?['content'];

    if (content == null || content.isEmpty) {
      return "Не смог получить ответ 😕";
    }

    return content.trim();
  }


  /// 🧩 Вспомогательная функция — извлечение чистого JSON
  static String _extractJson(String text) {
    final start = text.indexOf('[');
    final end = text.lastIndexOf(']');
    if (start != -1 && end != -1 && end > start) {
      return text.substring(start, end + 1);
    }
    final startObj = text.indexOf('{');
    final endObj = text.lastIndexOf('}');
    if (startObj != -1 && endObj != -1 && endObj > startObj) {
      return text.substring(startObj, endObj + 1);
    }
    return text;
  }
  /// 📸 Генерация рецепта по фотографии блюда
  static Future<UserRecipe> generateRecipeFromImage(String imagePath) async {
    final apiKey = dotenv.env['OPENAI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('OPENAI_API_KEY не задан в .env');
    }

    final bytes = await File(imagePath).readAsBytes();
    final base64Image = base64Encode(bytes);

    final body = json.encode({
      "model": _model,
      "messages": [
        {
          "role": "system",
          "content": "Ты — повар-ассистент. Определи блюдо по фотографии и создай рецепт."
        },
        {
          "role": "user",
          "content": [
            {
              "type": "input_text",
              "text":
              "Распознай блюдо по изображению и создай рецепт с ингредиентами, шагами, пользой и калорийностью."
            },
            {
              "type": "input_image",
              "image_url": "data:image/jpeg;base64,$base64Image"
            }
          ]
        }
      ],
      "max_tokens": 600
    });

    final res = await http.post(
      Uri.parse(_endpoint),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $apiKey"
      },
      body: body,
    );

    if (res.statusCode != 200) {
      throw Exception("OpenAI error: ${res.statusCode} ${res.body}");
    }

    final data = json.decode(res.body);
    final content = data["choices"]?[0]?["message"]?["content"] ?? "Рецепт не найден";

    // Создаем UserRecipe
    return UserRecipe(
      title: "Распознанное блюдо",
      description: content,
      ingredients: ["Не удалось извлечь"],
      steps: ["Не удалось извлечь"],
      rating: 0,
      imagePath: imagePath,
    );
  }

}

