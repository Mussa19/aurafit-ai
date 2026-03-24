import 'package:flutter/material.dart';

import '../widgets/feature_card.dart';
import '../widgets/progress_card.dart';

import 'camera_screen.dart';
import 'food_screen.dart';
import 'plan_screen.dart';
import 'schedule_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AuraFit AI"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Progress overview section
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ProgressCard(title: "Calories", value: "1800"),
                ProgressCard(title: "Workouts", value: "4"),
              ],
            ),

            const SizedBox(height: 30),

            // Feature Grid
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                children: [
                  FeatureCard(
                    title: "Scan Food",
                    icon: Icons.camera_alt,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CameraScreen()),
                      );
                    },
                  ),
                  FeatureCard(
                    title: "Workout Plan",
                    icon: Icons.fitness_center,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PlanScreen()),
                      );
                    },
                  ),
                  FeatureCard(
                    title: "Schedule",
                    icon: Icons.calendar_month,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ScheduleScreen()),
                      );
                    },
                  ),
                  FeatureCard(
                    title: "Nutrition",
                    icon: Icons.restaurant,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const FoodScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}