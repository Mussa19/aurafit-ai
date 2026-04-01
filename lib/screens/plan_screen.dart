import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/ai_service.dart';

class PlanScreen extends StatefulWidget {
  const PlanScreen({super.key});

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  late Future<List<Map<String, String>>> _workoutPlan;

  @override
  void initState() {
    super.initState();
    _workoutPlan = _loadDataAndFetchPlan();
  }

  // Загрузка данных профиля и запрос к Gemini
  Future<List<Map<String, String>>> _loadDataAndFetchPlan() async {
    final prefs = await SharedPreferences.getInstance();
    // Берем те самые 80кг и 185см из памяти
    final weight = prefs.getString('user_weight') ?? "70";
    final height = prefs.getString('user_height') ?? "175";

    final aiResponse = await AiService.generateWorkout(
      weight: weight,
      height: height,
    );

    List<Map<String, String>> plan = [];
    final lines = aiResponse.split('\n');
    
    for (var line in lines) {
      // Ищем строки формата "Упражнение: Подходы х Повторения"
      if (line.contains(':') || line.contains(' - ')) {
        final parts = line.split(RegExp(r'[:\-]'));
        if (parts.length >= 2) {
          plan.add({
            "title": parts[0].trim().replaceAll('*', '').replaceAll(RegExp(r'^\d+\.\s*'), ''),
            "subtitle": parts[1].trim(),
          });
        }
      }
    }

    if (plan.isEmpty) {
      return [
        {"title": "Personalized AI Plan", "subtitle": "Focusing on $weight kg weight"},
        {"title": "Note", "subtitle": "Try refreshing for a detailed list"},
      ];
    }
    return plan;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F13),
      appBar: AppBar(
        title: const Text("AI Personalized Plan", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _workoutPlan = _loadDataAndFetchPlan();
              });
            },
          )
        ],
      ),
      body: FutureBuilder<List<Map<String, String>>>(
        future: _workoutPlan,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.deepPurpleAccent),
                  SizedBox(height: 20),
                  Text("AI is analyzing your 80kg / 185cm profile...", 
                    style: TextStyle(color: Colors.white70)),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return const Center(child: Text("Connection Error", style: TextStyle(color: Colors.red)));
          } else {
            final exercises = snapshot.data ?? [];
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: exercises.length,
              itemBuilder: (context, index) {
                final item = exercises[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.deepPurpleAccent,
                      child: Icon(Icons.fitness_center, color: Colors.white, size: 20),
                    ),
                    title: Text(item['title']!, 
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Text(item['subtitle']!, 
                      style: const TextStyle(color: Colors.white70)),
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