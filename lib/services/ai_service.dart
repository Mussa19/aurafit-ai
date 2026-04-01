import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';

class AiService {
  static const String apiKey = "AIzaSyCPkYY91Pq586Y1LtjZazrVQxT3DUbvzZ8"; 

  
  static Future<String> analyzeFood(File image) async {
    try {
      
      final model = GenerativeModel(
        model: 'models/gemini-1.5-flash', 
        apiKey: apiKey
      );
      
      final imageBytes = await image.readAsBytes();
      
      // Формируем контент. Для картинок используем DataPart.
      final content = [
        Content.multi([
          TextPart("Analyze this food image. Tell calories and what food it is. Give a very short answer."),
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
      final model = GenerativeModel(
        model: 'models/gemini-1.5-flash', 
        apiKey: apiKey,
      );

      final content = [
        Content.text("Create a simple workout plan for a person with this goal: $goal. List 5 exercises with sets and reps.")
      ];
      
      final response = await model.generateContent(content);
      return response.text ?? "AI could not generate a plan.";
    } catch (e) {
      return "Error connecting to AI: $e";
    }
  }
}