import 'dart:io';
import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';

class FoodScannerService {
  final String _apiKey = "YOUR_API_KEY_HERE";
  late final GenerativeModel _model;

  FoodScannerService() {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: _apiKey,
      // We force the output to be JSON for easy parsing
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
      ),
    );
  }

  Future<Map<String, dynamic>?> analyzeFoodImage(File imageFile) async {
    try {
      final imageBytes = await imageFile.readAsBytes();
      
      // Multi-modal content: Image + Text Prompt
      final content = [
        Content.multi([
          DataPart('image/jpeg', imageBytes),
          TextPart("""
            Identify the food in this image. 
            Provide the estimated calories, protein, carbs, and fats.
            Respond in this JSON format:
            {
              "foodName": "string",
              "calories": number,
              "protein": number,
              "carbs": number,
              "fats": number,
              "confidence": number
            }
          """),
        ])
      ];

      final response = await _model.generateContent(content);
      
      if (response.text != null) {
        return jsonDecode(response.text!) as Map<String, dynamic>;
      }
    } catch (e) {
      print("Error scanning food: $e");
    }
    return null;
  }
}