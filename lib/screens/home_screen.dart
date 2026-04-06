import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/feature_card.dart';
import '../widgets/progress_card.dart';
import 'camera_screen.dart';
import 'plan_screen.dart'; 
import 'profile_screen.dart';
import 'schedule_screen.dart';
import 'nutrition_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String userWeight = "--"; 
  String dailyCalories = "0"; 

  @override
  void initState() {
    super.initState();
    _loadUserData(); 
  }

  // Загружаем данные из облака, чтобы они совпадали с профилем
  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        String weight = data['weight']?.toString() ?? "70";

        if (!mounted) return;
        setState(() {
          userWeight = weight;
          int weightInt = int.tryParse(weight) ?? 70;
          dailyCalories = (weightInt * 30).toString(); 
        });

        // Сохраняем в кэш на всякий случай
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_weight', weight);
      }
    } catch (e) {
      // Если нет интернета, берем из кэша
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      setState(() {
        userWeight = prefs.getString('user_weight') ?? "70";
        int weightInt = int.tryParse(userWeight) ?? 70;
        dailyCalories = (weightInt * 30).toString();
      });
    }
  }

  // Ждем возврата из профиля и обновляем данные
  Future<void> _navigateTo(BuildContext context, Widget screen) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
    _loadUserData(); 
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
            onPressed: () => _navigateTo(context, const ProfileScreen()),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadUserData, // Позволяет обновить данные, потянув экран вниз
        color: Colors.deepPurpleAccent,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
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
                  FeatureCard(
                    title: "Schedule",
                    icon: Icons.calendar_today_rounded,
                    onTap: () => _navigateTo(context, const ScheduleScreen()),
                  ),
                  FeatureCard(
                    title: "Nutrition",
                    icon: Icons.restaurant_rounded,
                    onTap: () => _navigateTo(context, const NutritionScreen()),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}