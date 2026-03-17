import 'package:flutter/material.dart';

class PlanScreen extends StatelessWidget {

  const PlanScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Workout Plan"),
      ),
      body: const Center(
        child: Text("AI generated workout plan"),
      ),
    );
  }
}