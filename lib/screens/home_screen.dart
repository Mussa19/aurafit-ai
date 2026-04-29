import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/aurafit_logo.dart';
import '../widgets/feature_card.dart';
import '../widgets/progress_card.dart';
import 'camera_screen.dart';
import 'nutrition_screen.dart';
import 'plan_screen.dart';
import 'profile_screen.dart';
import 'schedule_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onThemeToggle;

  const HomeScreen({super.key, required this.onThemeToggle});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String userWeight = '--';
  String dailyCalories = '0';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        final weight = data['weight']?.toString() ?? '70';

        if (!mounted) return;

        setState(() {
          userWeight = weight;
          final weightNum = double.tryParse(weight) ?? 70.0;
          dailyCalories = (weightNum * 30).toInt().toString();
        });

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_weight', weight);
      }
    } catch (_) {
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;

      setState(() {
        userWeight = prefs.getString('user_weight') ?? '70';
        final weightNum = double.tryParse(userWeight) ?? 70.0;
        dailyCalories = (weightNum * 30).toInt().toString();
      });
    }
  }

  Future<void> _navigateTo(BuildContext context, Widget screen) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
    _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AuraFitLogo(size: 34, showWordmark: false),
            SizedBox(width: 10),
            Text('AuraFit AI', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6_outlined),
            onPressed: widget.onThemeToggle,
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined, size: 28),
            onPressed: () => _navigateTo(
              context,
              ProfileScreen(onThemeToggle: widget.onThemeToggle),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadUserData,
        color: scheme.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Text(
                'Weight: $userWeight kg',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.75),
                ),
              ),
              Text(
                'Your Daily Summary',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              ProgressCard(calories: dailyCalories, workouts: '4'),
              const SizedBox(height: 30),
              Text(
                'Features',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.75),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 15),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                children: [
                  FeatureCard(
                    title: 'Scan Food',
                    icon: Icons.camera_alt_rounded,
                    onTap: () => _navigateTo(
                      context,
                      CameraScreen(onThemeToggle: widget.onThemeToggle),
                    ),
                  ),
                  FeatureCard(
                    title: 'Workout Plan',
                    icon: Icons.bolt_rounded,
                    onTap: () => _navigateTo(context, const PlanScreen()),
                  ),
                  FeatureCard(
                    title: 'Schedule',
                    icon: Icons.calendar_today_rounded,
                    onTap: () => _navigateTo(context, const ScheduleScreen()),
                  ),
                  FeatureCard(
                    title: 'Nutrition',
                    icon: Icons.restaurant_rounded,
                    onTap: () => _navigateTo(
                      context,
                      NutritionScreen(onThemeToggle: widget.onThemeToggle),
                    ),
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
