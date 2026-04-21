import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AiService {
  // Геттер для безопасного получения ключа из .env
  static String get _apiKey => dotenv.env['GROQ_API_KEY'] ?? '';

  static const String _url = 'https://api.groq.com/openai/v1/chat/completions';

  // Модели (актуальные на сегодня)
  static const String _textModel = 'llama-3.3-70b-versatile';
  static const String _visionModel = 'llama-3.2-11b-vision-preview';

  /// --- 1. АНАЛИЗ ИЗОБРАЖЕНИЙ (ЕДА И ТЕЛО) ---
  static Future<String> analyzeImage(Uint8List imageBytes, String promptType) async {
    if (_apiKey.isEmpty) {
      return "Ошибка: API ключ не найден. Проверьте файл .env и перезапустите приложение.";
    }

    final String base64Image = base64Encode(imageBytes);

    // Настройка промпта
    String systemPrompt = promptType == "food"
        ? "Analyze this food image. Provide estimated calories, proteins, fats, and carbs. Be concise and professional."
        : "Analyze this fitness progress photo. Estimate body fat percentage and muscle definition. Give professional advice.";

    try {
      final response = await http.post(
        Uri.parse(_url),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': _visionModel,
          'messages': [
            {
              'role': 'user',
              'content': [
                {'type': 'text', 'text': systemPrompt},
                {
                  'type': 'image_url',
                  'image_url': {'url': 'data:image/jpeg;base64,$base64Image'}
                },
              ],
            }
          ],
          'temperature': 0.5,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } 
      
      // Ловим ошибки моделей (400, 404) для Google Play
      if (response.statusCode == 400 || response.statusCode == 404) {
        debugPrint("Groq Model Error: ${response.body}");
        return "Сервер AI обновляется, функция анализа фото будет доступна через пару часов. Пожалуйста, попробуйте позже!";
      }

      return "Ошибка сервера (${response.statusCode}). Попробуйте позже.";
    } catch (e) {
      return "Ошибка сети: $e. Проверьте интернет-соединение.";
    }
  }

  /// --- 2. ГЕНЕРАЦИЯ ПЛАНА (ТРЕНИРОВКИ/ПИТАНИЕ) ---
  static Future<String> generateSchedule({required String weight, required String height}) async {
    if (_apiKey.isEmpty) return "Ошибка: API ключ не найден.";

    try {
      final response = await http.post(
        Uri.parse(_url),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': _textModel,
          'messages': [
            {
              'role': 'system',
              'content': 'You are a professional fitness and nutrition coach. Create clear, actionable plans.'
            },
            {
              'role': 'user',
              'content': 'Create a workout and meal plan for: Weight $weight kg, Height $height cm.'
            }
          ],
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        return "Не удалось сгенерировать план. Ошибка: ${response.statusCode}";
      }
    } catch (e) {
      return "Ошибка связи с AI: $e";
    }
  }

  /// --- 3. ДЕБАГ (ДЛЯ ПРОВЕРКИ В КОНСОЛИ) ---
  static void checkStatus() {
    print("--- AI Service Status ---");
    print("API Key exists: ${_apiKey.isNotEmpty}");
    if (_apiKey.isNotEmpty) {
      print("Key preview: ${_apiKey.substring(0, 5)}...");
    }
    print("-------------------------");
  }
}