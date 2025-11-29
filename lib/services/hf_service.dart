import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class HFService {
  static final String _apiKey = dotenv.env['HUGGINGFACE_API_KEY'] ?? '';
  static final String _model =
      dotenv.env['HUGGINGFACE_MODEL'] ?? 'google/vit-base-patch16-224';


  /// Распознаёт блюдо на фото
  static Future<String> recognizeFood(File imageFile) async {
    try {
      if (_apiKey.isEmpty) {
        throw Exception('Hugging Face API ключ не найден в .env');
      }


      final uri = Uri.parse('https://router.huggingface.co/hf-inference/models/$_model');
      final headers = {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/octet-stream',
      };

    final bytes = await imageFile.readAsBytes();

      final response = await http.post(uri, headers: headers, body: bytes);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is List && data.isNotEmpty && data[0]['label'] != null) {
          return data[0]['label'];
        } else {
          return 'Не удалось определить блюдо';
        }
      } else {
        print('Ошибка Hugging Face (${response.statusCode}): ${response.body}');
        throw Exception(
            'Ошибка Hugging Face: ${response.statusCode}. Проверь модель или API ключ.');
      }
    } catch (e) {
      throw Exception('Ошибка распознавания: $e');
    }
  }
}
