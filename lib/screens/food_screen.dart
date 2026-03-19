import 'package:flutter/material.dart';

class FoodScreen extends StatelessWidget {
  const FoodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nutrition"),
      ),
      // Added a body here to fix the syntax error
      body: const Center(
        child: Text(
          "Nutritional information will appear here",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}