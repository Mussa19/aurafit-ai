import 'package:flutter/material.dart';
import '../models/food_model.dart';

class FoodScreen extends StatelessWidget {
  const FoodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data: In the future, this comes from your AI Service
    final List<FoodModel> loggedMeals = [
      FoodModel(name: "Oatmeal with Berries", calories: 350, protein: 12, carbs: 60, fat: 5),
      FoodModel(name: "Grilled Chicken Salad", calories: 450, protein: 40, carbs: 10, fat: 15),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Nutrition Tracker"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Daily Summary Card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  MacroWidget(label: "Protein", value: "52g", color: Colors.red),
                  MacroWidget(label: "Carbs", value: "70g", color: Colors.orange),
                  MacroWidget(label: "Fat", value: "20g", color: Colors.blue),
                ],
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text("Recent Meals", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),

            // 2. List of Meals
            ListView.builder(
              shrinkWrap: true, // Needed inside SingleChildScrollView
              physics: const NeverScrollableScrollPhysics(),
              itemCount: loggedMeals.length,
              itemBuilder: (context, index) {
                final meal = loggedMeals[index];
                return ListTile(
                  leading: const Icon(Icons.fastfood, color: Colors.green),
                  title: Text(meal.name),
                  subtitle: Text("${meal.calories} kcal | P: ${meal.protein}g C: ${meal.carbs}g F: ${meal.fat}g"),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Simple helper widget for the top bar
class MacroWidget extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const MacroWidget({super.key, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}