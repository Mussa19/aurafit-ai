import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AURAFIT AI", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildMenuCard(context, "Camera", Icons.camera_alt, Colors.blueAccent),
            _buildMenuCard(context, "Analyze", Icons.analytics, Colors.purpleAccent),
            _buildMenuCard(context, "Workout Plan", Icons.fitness_center, Colors.orangeAccent),
            _buildMenuCard(context, "Food Plan", Icons.restaurant, Colors.greenAccent),
            _buildMenuCard(context, "Schedule", Icons.calendar_month, Colors.redAccent),
            _buildMenuCard(context, "Progress", Icons.show_chart, Colors.tealAccent),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, String title, IconData icon, Color color) {
    return InkWell(
      onTap: () {
        // Simple routing logic based on title
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Opening $title...")));
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: const Color(0xFF1E1E2E),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}