import '../models/workout_model.dart';
import '../models/food_model.dart';

class AIService {
  // Simulates AI generating a workout plan based on a goal
  Future<List<WorkoutExercise>> generateWorkoutPlan(String goal) async {
    // Simulate network delay (2 seconds)
    await Future.delayed(const Duration(seconds: 2));

    if (goal == "Strength") {
      return [
        WorkoutExercise(name: "Deadlifts", sets: 5, reps: "5"),
        WorkoutExercise(name: "Overhead Press", sets: 4, reps: "8"),
        WorkoutExercise(name: "Pull Ups", sets: 3, reps: "Max"),
      ];
    } else {
      return [
        WorkoutExercise(name: "Running", sets: 1, reps: "30 min"),
        WorkoutExercise(name: "Jump Rope", sets: 3, reps: "2 min"),
        WorkoutExercise(name: "Burpees", sets: 4, reps: "15"),
      ];
    }
  }

  // Simulates AI analyzing a food image
  Future<FoodModel> analyzeFoodImage(String imagePath) async {
    // Simulate AI processing time
    await Future.delayed(const Duration(seconds: 3));

    // In a real app, this data comes from the AI's vision API
    return FoodModel(
      name: "Chicken Avocado Toast",
      calories: 420,
      protein: 28.5,
      carbs: 35.0,
      fat: 18.0,
    );
  }
}