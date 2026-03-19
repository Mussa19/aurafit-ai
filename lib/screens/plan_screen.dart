import 'package:flutter/material.dart';
import '../models/workout_model.dart'; // Import your new model

class PlanScreen extends StatelessWidget {
  const PlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Now using the Model Class instead of a Map!
    final List<WorkoutExercise> workoutPlan = [
      WorkoutExercise(name: "Push Ups", sets: 3, reps: "15"),
      WorkoutExercise(name: "Bench Press", sets: 4, reps: "10"),
      WorkoutExercise(name: "Dumbbell Flyes", sets: 3, reps: "12"),
      WorkoutExercise(name: "Plank", sets: 3, reps: "60 sec"),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Workout Plan"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: workoutPlan.length,
        padding: const EdgeInsets.symmetric(vertical: 10),
        itemBuilder: (context, index) {
          final exercise = workoutPlan[index]; // Reference the object
          
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.fitness_center, color: Colors.deepPurple),
              title: Text(exercise.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("${exercise.sets} Sets x ${exercise.reps}"),
              trailing: Icon(
                exercise.isCompleted ? Icons.check_circle : Icons.circle_outlined,
                color: exercise.isCompleted ? Colors.green : Colors.grey,
              ),
            ),
          );
        },
      ),
    );
  }
}