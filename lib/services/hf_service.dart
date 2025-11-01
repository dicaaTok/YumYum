import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class HuggingFaceService {
  static const _model = 'nateraw/food'; // Модель распознавания еды

  /// 🧠 Распознаёт блюдо по изображению (File)
  static Future<String> recognizeFood(File imageFile) async {
    final hfToken = dotenv.env['HUGGINGFACE_API_TOKEN'];
    if (hfToken == null || hfToken.isEmpty) {
      throw Exception('HUGGINGFACE_API_TOKEN не задан в .env');
    }

    final url = Uri.parse('https://api-inference.huggingface.co/models/$_model');
    final bytes = await imageFile.readAsBytes();

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $hfToken',
        'Content-Type': 'application/octet-stream',
      },
      body: bytes,
    );

    if (response.statusCode == 200) {
      final result = json.decode(utf8.decode(response.bodyBytes));

      if (result is List && result.isNotEmpty && result[0]['label'] != null) {
        return result[0]['label'];
      } else {
        return 'Не удалось распознать блюдо 😕';
      }
    } else {
      throw Exception(
        'Ошибка HuggingFace (${response.statusCode}): ${response.body}',
      );
    }
  }
}
