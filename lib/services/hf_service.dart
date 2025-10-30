import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class HuggingFaceService {
  final String _model = 'nateraw/food'; // модель для распознавания еды

  Future<String> recognizeFood(File imageFile) async {
    final token = dotenv.env['HUGGINGFACE_API_TOKEN'];
    if (token == null || token.isEmpty) {
      throw Exception('Hugging Face token not set in .env');
    }

    final url = Uri.parse('https://api-inference.huggingface.co/models/$_model');
    final bytes = await imageFile.readAsBytes();

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/octet-stream',
      },
      body: bytes,
    );

    if (response.statusCode == 200) {
      // Ожидаем список предсказаний [{label:, score:}, ...]
      final dynamic parsed = json.decode(utf8.decode(response.bodyBytes));
      if (parsed is List && parsed.isNotEmpty) {
        // Возьмём лучшую метку
        final label = parsed[0]['label'] ?? 'unknown';
        return label.toString();
      } else {
        return 'Не распознано';
      }
    } else {
      throw Exception('HuggingFace API error: ${response.statusCode} ${response.body}');
    }
  }
}
