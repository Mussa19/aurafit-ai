
import 'package:flutter/material.dart';

class FoodScreen extends StatelessWidget {
  const FoodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nutrition Plan")),
      body: ListView(
        children: const [
          ListTile(title: Text("Breakfast: Eggs + Oatmeal")),
          ListTile(title: Text("Lunch: Chicken + Rice")),
          ListTile(title: Text("Dinner: Salmon + Vegetables")),
        ],
      ),
    );
  }
}
