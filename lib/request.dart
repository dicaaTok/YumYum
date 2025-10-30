import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<String> getRecipeFromOpenAI(String query) async {
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
          'content': 'Ты — ИИ-помощник по кулинарии. Говоришь просто и дружелюбно.'
        },
        {
          'role': 'user',
          'content': 'Как приготовить $query? Укажи шаги и калорийность.'
        }
      ],
      'max_tokens': 500,
    }),
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return data['choices'][0]['message']['content'];
  } else {
    throw Exception('Ошибка: ${response.body}');
  }
}
