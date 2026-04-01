import 'package:flutter/material.dart';


class PlanScreen extends StatefulWidget {
  const PlanScreen({super.key});

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  late Future<List<dynamic>> _workoutPlan;

  @override
  void initState() {
    super.initState();
    _workoutPlan = _fetchAIPlan();
  }

  Future<List<dynamic>> _fetchAIPlan() async {
    // Симуляция запроса к AI (пока твой APIService не готов)
    await Future.delayed(const Duration(seconds: 2)); 
    return [
      {"title": "Push Ups (AI Custom)", "subtitle": "3 Sets x 15"},
      {"title": "Bench Press", "subtitle": "4 Sets x 10"},
      {"title": "Dumbbell Flyes", "subtitle": "3 Sets x 12"},
      {"title": "Plank", "subtitle": "3 Sets x 60 sec"},
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F13),
      appBar: AppBar(
        title: const Text("AI Workout Plan", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _workoutPlan = _fetchAIPlan();
              });
            },
          )
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _workoutPlan,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.deepPurpleAccent),
                  SizedBox(height: 20),
                  Text("AI is crafting your plan...", style: TextStyle(color: Colors.white70)),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return const Center(child: Text("Error loading plan", style: TextStyle(color: Colors.red)));
          } else {
            final exercises = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: exercises.length,
              itemBuilder: (context, index) {
                final item = exercises[index];
                //  ListTile 
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    leading: const CircleAvatar(
                      backgroundColor: Colors.deepPurpleAccent,
                      child: Icon(Icons.fitness_center, color: Colors.white, size: 20),
                    ),
                    title: Text(
                      item['title'],
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      item['subtitle'],
                      style: const TextStyle(color: Colors.white70),
                    ),
                    trailing: const Icon(Icons.check_circle_outline, color: Colors.white24),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}