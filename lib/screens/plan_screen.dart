import 'package:flutter/material.dart';

class PlanScreen extends StatelessWidget {
  const PlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Basic dummy data for your AI-generated plan
    final List<Map<String, String>> exercises = [
      {"name": "Push Ups", "sets": "3", "reps": "15"},
      {"name": "Squats", "sets": "4", "reps": "12"},
      {"name": "Plank", "sets": "3", "reps": "60 sec"},
      {"name": "Lunges", "sets": "3", "reps": "10 each leg"},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Workout Plan"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              "Today's AI Recommendation:",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: exercises.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blueAccent,
                      child: Text("${index + 1}", style: const TextStyle(color: Colors.white)),
                    ),
                    title: Text(
                      exercises[index]["name"]!,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text("Sets: ${exercises[index]["sets"]} | Reps: ${exercises[index]["reps"]}"),
                    trailing: const Icon(Icons.check_circle_outline, color: Colors.grey),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}