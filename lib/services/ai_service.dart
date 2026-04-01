import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AiService {
  static final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? ""; 

  static GenerativeModel _createModel() {
    return GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: _apiKey,
    );
  }

  static Future<String> analyzeFood(File image) async {
    try {
      final model = _createModel();
      final imageBytes = await image.readAsBytes();
      final content = [
        Content.multi([
          TextPart("Определи еду на фото и оцени калории. Отвечай кратко на русском."),
          DataPart('image/jpeg', imageBytes),
        ])
      ];
      final response = await model.generateContent(content);
      return response.text ?? "Ошибка анализа.";
    } catch (e) {
      return "Ошибка: $e";
    }
  }

  static Future<String> generateWorkout({required String weight, required String height}) async {
    try {
      final model = _createModel();
      final prompt = "5 упражнений для $weight кг, $height см. На русском. Формат: Название: Сеты x Повторы.";
      final response = await model.generateContent([Content.text(prompt)]);
      return response.text ?? "Ошибка генерации.";
    } catch (e) {
      return "Ошибка: $e";
    }
  }

  static Future<String> generateSchedule({required String weight, required String height}) async {
    try {
      final model = _createModel();
      final prompt = "План на 7 дней для $weight кг, $height см. Кратко на русском.";
      final response = await model.generateContent([Content.text(prompt)]);
      return response.text ?? "Ошибка расписания.";
    } catch (e) {
      return "Ошибка: $e";
    }
  }
}