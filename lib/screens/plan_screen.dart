
import 'package:flutter/material.dart';

class PlanScreen extends StatelessWidget {
  const PlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Workout Plan")),
      body: ListView(
        children: const [
          ListTile(title: Text("Monday - Chest")),
          ListTile(title: Text("Tuesday - Back")),
          ListTile(title: Text("Wednesday - Rest")),
          ListTile(title: Text("Thursday - Legs")),
          ListTile(title: Text("Friday - Shoulders")),
        ],
      ),
    );
  }
}
