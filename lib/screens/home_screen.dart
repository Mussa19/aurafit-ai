import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/feature_card.dart';
import '../widgets/progress_card.dart';
import 'camera_screen.dart';
import 'plan_screen.dart'; 
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String userWeight = "--"; 
  String dailyCalories = "2100"; 

  @override
  void initState() {
    super.initState();
    _loadUserData(); 
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      userWeight = prefs.getString('user_weight') ?? "70";
      int weightInt = int.tryParse(userWeight) ?? 70;
      dailyCalories = (weightInt * 30).toString(); 
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F13),
      appBar: AppBar(
        title: const Text("AuraFit AI", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined, size: 28, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Text(
              "Weight: $userWeight kg", 
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const Text(
              "Your Daily Summary",
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            ProgressCard(
              calories: dailyCalories,
              workouts: "4",
            ),

            const SizedBox(height: 30),
            const Text(
              "Features",
              style: TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 15),

            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 1.0,
                children: [
                  FeatureCard(
                    title: "Scan Food",
                    icon: Icons.camera_alt_rounded,
                    onTap: () => _navigateTo(context, const CameraScreen()),
                  ),
                  FeatureCard(
                    title: "Workout Plan",
                    icon: Icons.bolt_rounded,
                    onTap: () => _navigateTo(context, const PlanScreen()),
                  ),
                  // Заглушки для функций, которые в разработке
                  FeatureCard(
                    title: "Schedule",
                    icon: Icons.calendar_today_rounded,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Schedule coming soon!")),
                      );
                    },
                  ),
                  FeatureCard(
                    title: "Nutrition",
                    icon: Icons.restaurant_rounded,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Nutrition tracking coming soon!")),
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

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }
}