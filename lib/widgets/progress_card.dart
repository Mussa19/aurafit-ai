import 'package:flutter/material.dart';

class ProgressCard extends StatelessWidget {
  final String calories;
  final String workouts;

  const ProgressCard({super.key, required this.calories, required this.workouts});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStat(context, 'Calories', calories, Icons.local_fire_department, Colors.orange),
          Container(width: 1, height: 30, color: scheme.outline.withValues(alpha: 0.4)),
          _buildStat(context, 'Workouts', workouts, Icons.fitness_center, Colors.blueAccent),
        ],
      ),
    );
  }

  Widget _buildStat(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(color: scheme.onSurface, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(color: scheme.onSurface.withValues(alpha: 0.65), fontSize: 12, letterSpacing: 0.5),
        ),
      ],
    );
  }
}
