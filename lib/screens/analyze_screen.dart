import 'package:flutter/material.dart';

class AnalyzeScreen extends StatelessWidget {
  const AnalyzeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Body Analysis")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Center(
            child: CircleAvatar(
              radius: 60,
              backgroundColor: Colors.purple,
              child: Icon(Icons.person_search, size: 60, color: Colors.white),
            ),
          ),
          const SizedBox(height: 30),
          _buildMetricRow("Posture Score", "85/100", Colors.green),
          _buildMetricRow("Body Symmetry", "92%", Colors.blue),
          _buildMetricRow("Estimated Fat", "18.4%", Colors.orange),
          _buildMetricRow("Muscle Balance", "Optimized", Colors.purpleAccent),
          const SizedBox(height: 20),
          const Text(
            "AI Insights: Your left shoulder is slightly lower than your right. Consider adding more unilateral rows to your routine.",
            style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 18)),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}