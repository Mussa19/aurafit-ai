import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/ai_service.dart';

class PlanScreen extends StatefulWidget {
  const PlanScreen({super.key});

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  late Future<List<Map<String, String>>> _workoutPlan;
  String currentWeight = '';
  String currentHeight = '';

  @override
  void initState() {
    super.initState();
    _workoutPlan = _loadDataAndFetchPlan();
  }

  Future<List<Map<String, String>>> _loadDataAndFetchPlan() async {
    final prefs = await SharedPreferences.getInstance();

    final weight = prefs.getString('user_weight') ?? '70';
    final height = prefs.getString('user_height') ?? '175';

    if (mounted) {
      setState(() {
        currentWeight = weight;
        currentHeight = height;
      });
    }

    final aiResponse = await AiService.generateSchedule(weight: weight, height: height);

    final plan = <Map<String, String>>[];
    final lines = aiResponse.split('\n');

    for (final line in lines) {
      final cleanLine = line.replaceAll('*', '').replaceFirst(RegExp(r'^\d+\.\s*'), '').trim();
      if (cleanLine.isEmpty) continue;

      String? separator;
      if (cleanLine.contains(':')) {
        separator = ':';
      } else if (cleanLine.contains(' - ')) {
        separator = ' - ';
      } else if (cleanLine.contains(' — ')) {
        separator = ' — ';
      }

      if (separator == null) continue;

      final parts = cleanLine.split(separator);
      if (parts.length < 2) continue;

      plan.add({
        'title': parts.first.trim(),
        'subtitle': parts.sublist(1).join(separator).trim(),
      });
    }

    if (plan.isEmpty && aiResponse.trim().isNotEmpty) {
      return [
        {
          'title': 'Ваш план готов',
          'subtitle': aiResponse.trim(),
        }
      ];
    }

    return plan;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Personalized Plan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              setState(() {
                _workoutPlan = _loadDataAndFetchPlan();
              });
            },
          )
        ],
      ),
      body: FutureBuilder<List<Map<String, String>>>(
        future: _workoutPlan,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: scheme.primary),
                  const SizedBox(height: 20),
                  Text(
                    'AuraFit AI анализирует профиль: $currentWeight кг / $currentHeight см...',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: scheme.error, size: 40),
                  const SizedBox(height: 10),
                  const Text('Ошибка соединения'),
                  TextButton(
                    onPressed: () => setState(() => _workoutPlan = _loadDataAndFetchPlan()),
                    child: const Text('Повторить'),
                  )
                ],
              ),
            );
          }

          final exercises = snapshot.data ?? [];

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            itemCount: exercises.length,
            itemBuilder: (context, index) {
              final item = exercises[index];

              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.only(bottom: 15),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      scheme.surfaceContainerHighest.withValues(alpha: 0.7),
                      scheme.surfaceContainer.withValues(alpha: 0.5),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: scheme.outline.withValues(alpha: 0.35)),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: scheme.primary.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.fitness_center_rounded, color: scheme.primary, size: 24),
                  ),
                  title: Text(
                    item['title']!,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(item['subtitle']!, style: const TextStyle(fontSize: 14)),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
