import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';

class AiService {
  // 🔑 Your Gemini API Key - Fixed with a semicolon
  static const String apiKey = "AIzaSyCPkYY91Pq586Y1LtjZazrVQxT3DUbvzZ8"; 

  // 📸 Free Food Analysis (Gemini Flash 1.5)
  static Future<String> analyzeFood(File image) async {
    try {
      final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
      
      final imageBytes = await image.readAsBytes();
      final content = [
        Content.multi([
          TextPart("Analyze this food image. Tell calories and what food it is. Short answer."),
          DataPart('image/jpeg', imageBytes),
        ])
      ];

      final response = await model.generateContent(content);
      return response.text ?? "AI could not analyze the image.";
    } catch (e) {
      return "Error connecting to AI: $e";
    }
  }

  
  static Future<String> generateWorkout(String goal) async {
    try {
      // Change this line in both analyzeFood and generateWorkout:
      // Change the model string to include the "models/" prefix
      final model = GenerativeModel(
        model: 'models/gemini-1.5-flash', 
        apiKey: apiKey,
      );

      
      final content = [Content.text("Create a simple workout plan for: $goal")];
      final response = await model.generateContent(content);
      
      return response.text ?? "AI could not generate a plan.";
    } catch (e) {
      return "Error connecting to AI: $e";
    }
  }
}