import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/ai_service.dart';

class PlanScreen extends StatefulWidget {
  const PlanScreen({super.key});

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  late Future<List<Map<String, String>>> _workoutPlan;
  final TextEditingController _foodNoteController = TextEditingController();
  final TextEditingController _trainingNoteController = TextEditingController();
  String currentWeight = '';
  String currentHeight = '';
  bool _savingNotes = false;

  @override
  void initState() {
    super.initState();
    _loadSavedNotes();
    _workoutPlan = _loadDataAndFetchPlan();
  }

  @override
  void dispose() {
    _foodNoteController.dispose();
    _trainingNoteController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedNotes() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _foodNoteController.text = prefs.getString('daily_food_note') ?? '';
      _trainingNoteController.text = prefs.getString('daily_training_note') ?? '';
    });
  }

  String _buildPersonalNote() {
    final food = _foodNoteController.text.trim();
    final training = _trainingNoteController.text.trim();
    final parts = <String>[];
    if (food.isNotEmpty) parts.add('Today I ate / plan to eat: $food');
    if (training.isNotEmpty) parts.add('Today I want this training focus: $training');
    return parts.join('\n');
  }

  Future<void> _saveNotes() async {
    if (_savingNotes) return;
    setState(() => _savingNotes = true);

    final food = _foodNoteController.text.trim();
    final training = _trainingNoteController.text.trim();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('daily_food_note', food);
      await prefs.setString('daily_training_note', training);

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final today = DateTime.now();
        final docId = '${today.year}-${today.month}-${today.day}';
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('daily_notes')
            .doc(docId)
            .set({
          'foodNote': food,
          'trainingNote': training,
          'updatedAt': FieldValue.serverTimestamp(),
          'date': Timestamp.fromDate(DateTime(today.year, today.month, today.day)),
        }, SetOptions(merge: true));
      }

      if (!mounted) return;
      setState(() {
        _workoutPlan = _loadDataAndFetchPlan();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notes saved. AI plan updated.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save notes: $e')),
      );
    } finally {
      if (mounted) setState(() => _savingNotes = false);
    }
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

    final aiResponse = await AiService.generateSchedule(
      weight: weight,
      height: height,
      personalNote: _buildPersonalNote(),
    );

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
          'title': 'Your plan is ready',
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
                    'AuraFit AI is analyzing: $currentWeight kg / $currentHeight cm...',
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
                  const Text('Connection error'),
                  TextButton(
                    onPressed: () => setState(() => _workoutPlan = _loadDataAndFetchPlan()),
                    child: const Text('Retry'),
                  )
                ],
              ),
            );
          }

          final exercises = snapshot.data ?? [];

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
            children: [
              _heroCard(context, currentWeight, currentHeight),
              const SizedBox(height: 12),
              _notesCard(context),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _tag(context, 'AI Adaptive'),
                  _tag(context, 'Home + Gym'),
                  _tag(context, 'Goal Focus'),
                ],
              ),
              const SizedBox(height: 14),
              ...List.generate(exercises.length, (index) {
                final item = exercises[index];
                return _planTile(
                  context: context,
                  title: item['title'] ?? 'Plan item',
                  subtitle: item['subtitle'] ?? '',
                  index: index,
                );
              }),
            ],
          );
        },
      ),
    );
  }

  Widget _heroCard(BuildContext context, String weight, String height) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.primary.withValues(alpha: 0.22),
            const Color(0xFF1AEFFF).withValues(alpha: 0.18),
            scheme.surfaceContainerHigh.withValues(alpha: 0.65),
          ],
        ),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.32)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Neural Plan',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Built for $weight kg / $height cm profile',
                  style: TextStyle(
                    color: scheme.onSurface.withValues(alpha: 0.75),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 58,
            height: 58,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFF6D5EF7), Color(0xFF1AEFFF)],
              ),
            ),
            child: const Icon(Icons.auto_awesome_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _notesCard(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: scheme.surfaceContainerHigh.withValues(alpha: 0.45),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.edit_note_rounded, color: scheme.primary),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Today Notes For AI',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _noteField(
            controller: _foodNoteController,
            label: 'Food note (what you ate / want to eat)',
            icon: Icons.restaurant_menu_rounded,
          ),
          const SizedBox(height: 10),
          _noteField(
            controller: _trainingNoteController,
            label: 'Training note (what you want today)',
            icon: Icons.fitness_center_rounded,
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _savingNotes ? null : _saveNotes,
              icon: _savingNotes
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.auto_fix_high_rounded),
              label: Text(_savingNotes ? 'Saving...' : 'Save Notes & Regenerate Plan'),
            ),
          )
        ],
      ),
    );
  }

  Widget _noteField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return TextField(
      controller: controller,
      minLines: 1,
      maxLines: 3,
      style: TextStyle(color: scheme.onSurface),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: scheme.primary),
        filled: true,
        fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.outline.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.outline.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.primary.withValues(alpha: 0.85)),
        ),
      ),
    );
  }

  Widget _tag(BuildContext context, String label) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.55),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: scheme.onSurface.withValues(alpha: 0.9),
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _planTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required int index,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final icon = _iconFor(title);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.surfaceContainerHighest.withValues(alpha: 0.72),
            scheme.surfaceContainerHigh.withValues(alpha: 0.4),
          ],
        ),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.22)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [scheme.primary.withValues(alpha: 0.85), const Color(0xFF1AEFFF)],
              ),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: scheme.primary.withValues(alpha: 0.14),
                      ),
                      child: Text(
                        '#${index + 1}',
                        style: TextStyle(
                          color: scheme.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.35,
                    color: scheme.onSurface.withValues(alpha: 0.82),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconFor(String title) {
    final t = title.toLowerCase();
    if (t.contains('warm')) return Icons.local_fire_department_rounded;
    if (t.contains('cool')) return Icons.ac_unit_rounded;
    if (t.contains('chest')) return Icons.fitness_center_rounded;
    if (t.contains('back')) return Icons.accessibility_new_rounded;
    if (t.contains('leg')) return Icons.directions_run_rounded;
    if (t.contains('cardio')) return Icons.favorite_rounded;
    return Icons.bolt_rounded;
  }
}
