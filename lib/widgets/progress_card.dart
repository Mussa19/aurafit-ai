import 'package:flutter/material.dart';

class ProgressCard extends StatelessWidget {
  final String calories;
  final String workouts;

  const ProgressCard({super.key, required this.calories, required this.workouts});

  @override
  Widget build(BuildContext context) {
    return Container(
      // Убираем лишние внешние отступы, так как они уже заданы в HomeScreen
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        // ИСПРАВЛЕНО: .withValues вместо .withOpacity
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStat("Calories", calories, Icons.local_fire_department, Colors.orange),
          Container(width: 1, height: 30, color: Colors.white.withValues(alpha: 0.1)),
          _buildStat("Workouts", workouts, Icons.fitness_center, Colors.blueAccent),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 6),
        Text(
          value, 
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
        ),
        Text(
          label, 
          style: const TextStyle(color: Colors.grey, fontSize: 12, letterSpacing: 0.5)
        ),
      ],
    );
  }
}