import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/ai_service.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  late Future<String> _schedule;

  @override
  void initState() {
    super.initState();
    _schedule = _loadSchedule();
  }

  Future<String> _loadSchedule() async {
    final prefs = await SharedPreferences.getInstance();
    final weight = prefs.getString('user_weight') ?? "80";
    final height = prefs.getString('user_height') ?? "185";
    return AiService.generateSchedule(weight: weight, height: height);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F13),
      appBar: AppBar(title: const Text("AI Schedule"), backgroundColor: Colors.transparent),
      body: FutureBuilder<String>(
        future: _schedule,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Text(snapshot.data ?? "Error loading schedule", style: const TextStyle(color: Colors.white, fontSize: 16)),
          );
        },
      ),
    );
  }
}