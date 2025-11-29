// lib/services/hf_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class HFService {
  static final String _apiKey = dotenv.env['HUGGINGFACE_API_KEY'] ?? '';
  static final String _model = dotenv.env['HUGGINGFACE_MODEL'] ?? 'google/vit-base-patch16-224';

  /// Отправляет картинку в модель HuggingFace и возвращает строковую метку (label)
  /// Если вернулась сложная структура, пробуем получить наиболее вероятную метку.
  static Future<String> recognizeFood(File imageFile) async {
    if (_apiKey.isEmpty) {
      throw Exception('Hugging Face API ключ не найден в .env');
    }

    try {
      // В зависимости от модели HF иногда ожидает бинарные данные (octet-stream),
      // иногда JSON. Для классификации изображений обычно можно отправить bytes.
      final uri = Uri.parse('https://api-inference.huggingface.co/models/$_model');

      final bytes = await imageFile.readAsBytes();

      final headers = {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/octet-stream',
      };

      final response = await http.post(uri, headers: headers, body: bytes);

      if (response.statusCode == 200) {
        final body = response.body;

        // Пытаемся распарсить ответ
        final data = jsonDecode(body);

        // Ответ часто приходит как список с объектами {label: "...", score: ...}
        if (data is List && data.isNotEmpty) {
          final first = data.first;
          if (first is Map && first['label'] != null) {
            return first['label'].toString();
          }
        }

        // Если модель вернула Map с другими полями
        if (data is Map) {
          // Ищем ключи, которые похожи на label/name
          if (data.containsKey('label')) return data['label'].toString();
          if (data.containsKey('name')) return data['name'].toString();
          // Если есть prediction
          if (data.containsKey('predictions')) {
            final preds = data['predictions'];
            if (preds is List && preds.isNotEmpty && preds[0]['label'] != null) {
              return preds[0]['label'].toString();
            }
          }
        }

        // Если не удалось извлечь — вернём строковую форму ответа
        return 'Не удалось определить блюдо';
      } else {
        // выводим тело для дебага
        throw Exception('Hugging Face error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Ошибка распознавания: $e');
    }
  }
}
