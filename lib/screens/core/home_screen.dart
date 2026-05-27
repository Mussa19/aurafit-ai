import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/progress_service.dart';
import '../../widgets/aurafit_logo.dart';
import '../../widgets/feature_card.dart';
import '../../widgets/progress_card.dart';
import '../ai/camera_screen.dart';
import '../ai/nutrition_screen.dart';
import '../ai/plan_screen.dart';
import 'profile_screen.dart';
import '../ai/schedule_screen.dart';
import '../ai/track_progress_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onThemeToggle;

  const HomeScreen({super.key, required this.onThemeToggle});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ProgressService _progressService = ProgressService();
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

  Future<void> _openQuickLogSheet() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final weightCtrl = TextEditingController(text: userWeight == '--' ? '70' : userWeight);
    final stepsCtrl = TextEditingController(text: '3000');
    final waterCtrl = TextEditingController(text: '5');
    final workoutCtrl = TextEditingController(text: '24');
    bool saving = false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        final scheme = Theme.of(ctx).colorScheme;
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Log Today', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: _quickField(ctx, weightCtrl, 'Weight', suffix: 'kg')),
                      const SizedBox(width: 8),
                      Expanded(child: _quickField(ctx, stepsCtrl, 'Steps')),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: _quickField(ctx, waterCtrl, 'Water cups')),
                      const SizedBox(width: 8),
                      Expanded(child: _quickField(ctx, workoutCtrl, 'Workout min')),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: saving
                          ? null
                          : () async {
                              setModalState(() => saving = true);
                              try {
                                await _progressService.saveDailyLog(
                                  uid: uid,
                                  input: DailyLogInput(
                                    date: DateTime.now(),
                                    steps: int.tryParse(stepsCtrl.text.trim()) ?? 0,
                                    stepsGoal: 5000,
                                    waterCups: int.tryParse(waterCtrl.text.trim()) ?? 0,
                                    waterGoal: 8,
                                    workoutMinutes: int.tryParse(workoutCtrl.text.trim()) ?? 0,
                                    weightKg: double.tryParse(weightCtrl.text.trim()),
                                  ),
                                );
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Daily log saved')),
                                  );
                                  Navigator.pop(ctx);
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Save failed: $e'),
                                      backgroundColor: scheme.error,
                                    ),
                                  );
                                }
                              } finally {
                                setModalState(() => saving = false);
                              }
                            },
                      icon: saving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save_rounded),
                      label: Text(saving ? 'Saving...' : 'Save Daily Log'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _quickField(BuildContext context, TextEditingController ctrl, String label, {String? suffix}) {
    final scheme = Theme.of(context).colorScheme;
    return TextField(
      controller: ctrl,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        filled: true,
        fillColor: scheme.surfaceContainerHigh.withValues(alpha: 0.4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outline.withValues(alpha: 0.3)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 88,
        titleSpacing: 14,
        actionsPadding: const EdgeInsets.only(right: 8),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                scheme.surface.withValues(alpha: 0.96),
                scheme.surfaceContainerLowest.withValues(alpha: 0.96),
              ],
            ),
            border: Border(
              bottom: BorderSide(color: scheme.primary.withValues(alpha: 0.22)),
            ),
          ),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    scheme.surfaceContainerHighest.withValues(alpha: 0.85),
                    scheme.surfaceContainer.withValues(alpha: 0.6),
                  ],
                ),
                border: Border.all(color: scheme.primary.withValues(alpha: 0.3)),
              ),
              child: const AuraFitLogo(size: 26, showWordmark: false),
            ),
            const SizedBox(width: 12),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AuraFit AI',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'Cyber Performance',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: scheme.primary.withValues(alpha: 0.85),
                    letterSpacing: 0.6,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 6),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHigh.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: scheme.primary.withValues(alpha: 0.2)),
            ),
            child: IconButton(
              icon: const Icon(Icons.brightness_6_outlined),
              onPressed: widget.onThemeToggle,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 4),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHigh.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: scheme.primary.withValues(alpha: 0.2)),
            ),
            child: IconButton(
              icon: const Icon(Icons.account_circle_outlined, size: 26),
              onPressed: () => _navigateTo(
                context,
                ProfileScreen(onThemeToggle: widget.onThemeToggle),
              ),
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: scheme.primary.withValues(alpha: 0.22)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.monitor_weight_outlined, size: 16, color: scheme.primary),
                    const SizedBox(width: 6),
                    Text(
                      'Weight: $userWeight kg',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.82),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'Your Daily Summary',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              ProgressCard(
                calories: dailyCalories,
                workouts: '4',
                onTap: () => _navigateTo(
                  context,
                  TrackProgressScreen(weightKg: userWeight),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _navigateTo(
                    context,
                    TrackProgressScreen(weightKg: userWeight),
                  ),
                  icon: const Icon(Icons.insights_rounded),
                  label: const Text('OPEN TRACK PROGRESS'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _openQuickLogSheet,
                  icon: const Icon(Icons.add_chart_rounded),
                  label: const Text('LOG TODAY'),
                ),
              ),
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
                    title: 'Scan Body',
                    icon: Icons.accessibility_new_rounded,
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
                    title: 'Scan Food',
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

