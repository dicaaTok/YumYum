import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AIService {
  static Future<String> getRecipeFromOpenAI(String dishName) async {
    final apiKey = dotenv.env['OPENAI_API_KEY'];
    final url = Uri.parse('https://api.openai.com/v1/chat/completions');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: json.encode({
        'model': 'gpt-4o-mini',
        'messages': [
          {
            'role': 'system',
            'content': 'Ты — умный и дружелюбный кулинарный помощник.'
          },
          {
            'role': 'user',
            'content':
            'Как приготовить блюдо "$dishName"? Укажи ингредиенты, шаги, калорийность и насколько это полезно.'
          }
        ],
        'max_tokens': 600,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['choices'][0]['message']['content'];
    } else {
      throw Exception('Ошибка OpenAI: ${response.body}');
    }
  }
}
