
import 'package:flutter/material.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Workout Schedule")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text("Mon - Chest"),
            Text("Tue - Back"),
            Text("Wed - Rest"),
            Text("Thu - Legs"),
            Text("Fri - Shoulders"),
          ],
        ),
      ),
    );
  }
}
