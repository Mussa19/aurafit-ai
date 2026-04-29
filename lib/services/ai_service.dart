import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class AiService {
  static String _envOrDefault(String key, String fallback) {
    final value = dotenv.env[key]?.trim();
    if (value == null || value.isEmpty) {
      return fallback;
    }
    return value;
  }

  static String get _groqApiKey => dotenv.env['GROQ_API_KEY']?.trim() ?? '';
  static String get _geminiApiKey => dotenv.env['GEMINI_API_KEY']?.trim() ?? '';

  static bool get _hasGroq => _groqApiKey.isNotEmpty;
  static bool get _hasGemini => _geminiApiKey.isNotEmpty;

  static String get _groqUrl =>
      _envOrDefault('GROQ_API_URL', 'https://api.groq.com/openai/v1/chat/completions');
  static String get _groqTextModel =>
      _envOrDefault('GROQ_TEXT_MODEL', 'llama-3.3-70b-versatile');
  static String get _groqVisionModel =>
      _envOrDefault('GROQ_VISION_MODEL', 'meta-llama/llama-4-scout-17b-16e-instruct');

  static String get _geminiTextModel =>
      _envOrDefault('GEMINI_TEXT_MODEL', 'gemini-2.5-flash');
  static String get _geminiVisionModel =>
      _envOrDefault('GEMINI_VISION_MODEL', 'gemini-2.5-flash');

  static String get _noProviderMessage =>
      'AI не настроен. Добавьте в .env хотя бы один ключ: GROQ_API_KEY или GEMINI_API_KEY.';

  static Future<String> analyzeImage(Uint8List imageBytes, String promptType) async {
    final systemPrompt = promptType == 'food'
        ? 'Analyze this food image. Return calories, proteins, fats, carbs and one short advice.'
        : 'Analyze this fitness progress photo. Estimate body fat and muscle definition, then give one short advice.';

    return _runWithFallback(
      groqCall: _hasGroq
          ? () => _analyzeImageWithGroq(imageBytes: imageBytes, prompt: systemPrompt)
          : null,
      geminiCall: _hasGemini
          ? () => _analyzeImageWithGemini(imageBytes: imageBytes, prompt: systemPrompt)
          : null,
    );
  }

  static Future<String> generateSchedule({
    required String weight,
    required String height,
  }) async {
    final userPrompt = 'Create a weekly workout and meal plan for weight $weight kg and height $height cm. '
        'Keep it practical and concise.';

    return _runWithFallback(
      groqCall: _hasGroq
          ? () => _generateScheduleWithGroq(prompt: userPrompt)
          : null,
      geminiCall: _hasGemini
          ? () => _generateScheduleWithGemini(prompt: userPrompt)
          : null,
    );
  }

  static Future<String> _runWithFallback({
    required Future<String> Function()? groqCall,
    required Future<String> Function()? geminiCall,
  }) async {
    final calls = <({String name, Future<String> Function() run})>[];

    if (groqCall != null) {
      calls.add((name: 'Groq', run: groqCall));
    }
    if (geminiCall != null) {
      calls.add((name: 'Gemini', run: geminiCall));
    }

    if (calls.isEmpty) {
      return _noProviderMessage;
    }

    final errors = <String>[];

    for (final call in calls) {
      try {
        final result = await call.run();
        if (result.trim().isNotEmpty) {
          return result.trim();
        }
        errors.add('${call.name}: empty response');
      } catch (e) {
        errors.add('${call.name}: $e');
      }
    }

    return 'Оба AI-провайдера недоступны. Проверьте ключи и интернет.\n${errors.join('\n')}';
  }

  static Future<String> _analyzeImageWithGroq({
    required Uint8List imageBytes,
    required String prompt,
  }) async {
    final base64Image = base64Encode(imageBytes);

    final response = await http
        .post(
          Uri.parse(_groqUrl),
          headers: {
            'Authorization': 'Bearer $_groqApiKey',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'model': _groqVisionModel,
            'messages': [
              {
                'role': 'user',
                'content': [
                  {'type': 'text', 'text': prompt},
                  {
                    'type': 'image_url',
                    'image_url': {'url': 'data:image/jpeg;base64,$base64Image'}
                  },
                ],
              }
            ],
            'temperature': 0.3,
          }),
        )
        .timeout(const Duration(seconds: 45));

    return _extractGroqText(response);
  }

  static Future<String> _generateScheduleWithGroq({required String prompt}) async {
    final response = await http
        .post(
          Uri.parse(_groqUrl),
          headers: {
            'Authorization': 'Bearer $_groqApiKey',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'model': _groqTextModel,
            'messages': [
              {
                'role': 'system',
                'content': 'You are a professional fitness and nutrition coach. Create clear and actionable plans.'
              },
              {
                'role': 'user',
                'content': prompt,
              }
            ],
            'temperature': 0.6,
          }),
        )
        .timeout(const Duration(seconds: 45));

    return _extractGroqText(response);
  }

  static String _extractGroqText(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final choices = data['choices'] as List<dynamic>?;
    if (choices == null || choices.isEmpty) {
      throw Exception('Groq returned empty choices.');
    }

    final message = choices.first['message'] as Map<String, dynamic>?;
    final content = message?['content']?.toString().trim() ?? '';
    if (content.isEmpty) {
      throw Exception('Groq returned empty content.');
    }

    return content;
  }

  static Future<String> _analyzeImageWithGemini({
    required Uint8List imageBytes,
    required String prompt,
  }) async {
    final endpoint =
        'https://generativelanguage.googleapis.com/v1beta/models/$_geminiVisionModel:generateContent?key=$_geminiApiKey';

    final response = await http
        .post(
          Uri.parse(endpoint),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'contents': [
              {
                'parts': [
                  {
                    'inline_data': {
                      'mime_type': 'image/jpeg',
                      'data': base64Encode(imageBytes),
                    }
                  },
                  {'text': prompt},
                ],
              }
            ],
          }),
        )
        .timeout(const Duration(seconds: 45));

    return _extractGeminiText(response);
  }

  static Future<String> _generateScheduleWithGemini({required String prompt}) async {
    final endpoint =
        'https://generativelanguage.googleapis.com/v1beta/models/$_geminiTextModel:generateContent?key=$_geminiApiKey';

    final response = await http
        .post(
          Uri.parse(endpoint),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'contents': [
              {
                'parts': [
                  {
                    'text':
                        'You are a professional fitness and nutrition coach. Create clear and actionable plans.'
                  },
                  {'text': prompt},
                ],
              }
            ],
          }),
        )
        .timeout(const Duration(seconds: 45));

    return _extractGeminiText(response);
  }

  static String _extractGeminiText(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final candidates = data['candidates'] as List<dynamic>?;
    if (candidates == null || candidates.isEmpty) {
      final blockReason = (data['promptFeedback'] as Map<String, dynamic>?)?['blockReason'];
      if (blockReason != null) {
        throw Exception('Gemini blocked request: $blockReason');
      }
      throw Exception('Gemini returned no candidates.');
    }

    final first = candidates.first as Map<String, dynamic>;
    final content = first['content'] as Map<String, dynamic>?;
    final parts = content?['parts'] as List<dynamic>?;
    if (parts == null || parts.isEmpty) {
      throw Exception('Gemini returned no parts.');
    }

    final text = parts
        .whereType<Map<String, dynamic>>()
        .map((part) => part['text'])
        .whereType<String>()
        .join('\n')
        .trim();

    if (text.isEmpty) {
      throw Exception('Gemini returned empty text.');
    }

    return text;
  }

  static void checkStatus() {
    debugPrint('--- AI Service Status ---');
    debugPrint('Groq key exists: $_hasGroq');
    debugPrint('Gemini key exists: $_hasGemini');
    debugPrint('Groq text model: $_groqTextModel');
    debugPrint('Groq vision model: $_groqVisionModel');
    debugPrint('Gemini text model: $_geminiTextModel');
    debugPrint('Gemini vision model: $_geminiVisionModel');
    debugPrint('-------------------------');
  }
}

