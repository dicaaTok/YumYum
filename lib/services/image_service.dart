import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ImageService {
  static final _picker = ImagePicker();

  static Future<File?> pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      return File(picked.path);
    }
    return null;
  }

  static Future<String> recognizeFood(File imageFile) async {
    const hfToken = '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';
    final url = Uri.parse('https://api-inference.huggingface.co/models/nateraw/food');

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
      if (result is List && result.isNotEmpty) {
        return result[0]['label'];
      } else {
        return 'Не удалось распознать блюдо';
      }
    } else {
      throw Exception('Ошибка HuggingFace: ${response.statusCode}');
    }
  }
}
