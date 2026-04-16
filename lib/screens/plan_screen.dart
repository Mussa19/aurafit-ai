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
  String currentWeight = "";
  String currentHeight = "";

  @override
  void initState() {
    super.initState();
    _workoutPlan = _loadDataAndFetchPlan();
  }

  Future<List<Map<String, String>>> _loadDataAndFetchPlan() async {
    final prefs = await SharedPreferences.getInstance();
    
    final weight = prefs.getString('user_weight') ?? "70";
    final height = prefs.getString('user_height') ?? "175";
    
    if (mounted) {
      setState(() {
        currentWeight = weight;
        currentHeight = height;
      });
    }

    try {
      final aiResponse = await AiService.generateSchedule(
        weight: weight,
        height: height,
      );

      List<Map<String, String>> plan = [];
      final lines = aiResponse.split('\n');
      
      for (var line in lines) {
        if (line.contains(':') || line.contains(' — ') || line.contains(' - ')) {
          final cleanLine = line.replaceAll('*', '').replaceAll(RegExp(r'^\d+\.\s*'), '').trim();
          
          final separator = cleanLine.contains(':') ? ':' : (cleanLine.contains(' — ') ? ' — ' : ' - ');
          final parts = cleanLine.split(separator);
          
          if (parts.length >= 2) {
            plan.add({
              "title": parts[0].trim(),
              "subtitle": parts[1].trim(),
            });
          }
        }
      }

      if (plan.isEmpty && aiResponse.isNotEmpty) {
        return [{"title": "Ваш план готов", "subtitle": aiResponse}];
      }
      
      return plan;
    } catch (e) {
      throw Exception("Failed to fetch plan");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F13),
      appBar: AppBar(
        title: const Text("AI Personalized Plan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: Colors.deepPurpleAccent),
                  const SizedBox(height: 20),
                  Text(
                    "AuraFit AI анализирует профиль: $currentWeight кг / $currentHeight см...", 
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.redAccent, size: 40),
                  const SizedBox(height: 10),
                  const Text("Ошибка соединения", style: TextStyle(color: Colors.white)),
                  TextButton(
                    onPressed: () => setState(() => _workoutPlan = _loadDataAndFetchPlan()), 
                    child: const Text("Повторить")
                  )
                ],
              ),
            );
          } else {
            final exercises = snapshot.data ?? [];
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: exercises.length,
              itemBuilder: (context, index) {
                final item = exercises[index];
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(bottom: 15),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.08), 
                        Colors.white.withValues(alpha: 0.02)
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.deepPurpleAccent.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.fitness_center_rounded, color: Colors.deepPurpleAccent, size: 24),
                    ),
                    title: Text(item['title']!, 
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(item['subtitle']!, 
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 14)),
                    ),
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