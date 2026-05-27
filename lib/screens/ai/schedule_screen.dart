import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/progress_service.dart';
import '../../services/ai_service.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final ProgressService _progressService = ProgressService();
  late Future<List<_DayPlan>> _schedule;
  DateTime _visibleMonth = DateTime(DateTime.now().year, DateTime.now().month);
  final TextEditingController _weightCtrl = TextEditingController();
  final TextEditingController _stepsCtrl = TextEditingController();
  final TextEditingController _waterCtrl = TextEditingController();
  final TextEditingController _workoutCtrl = TextEditingController();
  bool _savingLog = false;

  @override
  void initState() {
    super.initState();
    _schedule = _loadSchedule();
    _initLogDefaults();
  }

  @override
  void dispose() {
    _weightCtrl.dispose();
    _stepsCtrl.dispose();
    _waterCtrl.dispose();
    _workoutCtrl.dispose();
    super.dispose();
  }

  Future<List<_DayPlan>> _loadSchedule() async {
    final prefs = await SharedPreferences.getInstance();
    final weight = prefs.getString('user_weight') ?? '70';
    final height = prefs.getString('user_height') ?? '175';
    final foodNote = prefs.getString('daily_food_note') ?? '';
    final trainingNote = prefs.getString('daily_training_note') ?? '';
    final personalNote = [
      if (foodNote.trim().isNotEmpty) 'Today I ate / plan to eat: ${foodNote.trim()}',
      if (trainingNote.trim().isNotEmpty) 'Today I want this training focus: ${trainingNote.trim()}',
    ].join('\n');

    final response = await AiService.generateSchedule(
      weight: weight,
      height: height,
      personalNote: personalNote,
    );

    return _parseDayPlans(response.replaceAll('*', '').trim());
  }

  Future<void> _initLogDefaults() async {
    final prefs = await SharedPreferences.getInstance();
    _weightCtrl.text = prefs.getString('user_weight') ?? '70';
    _stepsCtrl.text = '3000';
    _waterCtrl.text = '5';
    _workoutCtrl.text = '24';
    if (mounted) setState(() {});
  }

  List<_DayPlan> _parseDayPlans(String text) {
    final lines = text.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

    final dayRegex = RegExp(
      r'^(monday|tuesday|wednesday|thursday|friday|saturday|sunday)\b',
      caseSensitive: false,
    );

    final plans = <_DayPlan>[];
    _DayPlan? current;

    for (final line in lines) {
      final clean = line.replaceFirst(RegExp(r'^\d+\.\s*'), '');
      if (dayRegex.hasMatch(clean)) {
        current = _DayPlan(title: clean.replaceAll(':', ''), items: []);
        plans.add(current);
        continue;
      }

      if (current != null) {
        final item = clean.replaceFirst(RegExp(r'^[+\-•]\s*'), '');
        if (item.isNotEmpty) current.items.add(item);
      }
    }

    if (plans.isNotEmpty) return plans;
    return [_DayPlan(title: 'Full Plan', items: lines)];
  }

  Future<void> _toggleCompletion(String uid, DateTime day, bool done) async {
    final steps = int.tryParse(_stepsCtrl.text.trim()) ?? 3000;
    final water = int.tryParse(_waterCtrl.text.trim()) ?? 5;
    final workout = int.tryParse(_workoutCtrl.text.trim()) ?? 24;
    final weight = double.tryParse(_weightCtrl.text.trim());
    await _progressService.toggleCompletion(
      uid: uid,
      day: day,
      done: done,
      logDefaults: DailyLogInput(
        date: day,
        steps: steps,
        stepsGoal: 5000,
        waterCups: water,
        waterGoal: 8,
        workoutMinutes: workout,
        weightKg: weight,
      ),
    );
  }

  Future<void> _saveDailyLog(String uid) async {
    if (_savingLog) return;
    setState(() => _savingLog = true);
    try {
      final today = DateTime.now();
      final steps = int.tryParse(_stepsCtrl.text.trim()) ?? 0;
      final water = int.tryParse(_waterCtrl.text.trim()) ?? 0;
      final workout = int.tryParse(_workoutCtrl.text.trim()) ?? 0;
      final weight = double.tryParse(_weightCtrl.text.trim());

      await _progressService.saveDailyLog(
        uid: uid,
        input: DailyLogInput(
          date: today,
          steps: steps,
          stepsGoal: 5000,
          waterCups: water,
          waterGoal: 8,
          workoutMinutes: workout,
          weightKg: weight,
        ),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Daily log saved')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Save failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _savingLog = false);
    }
  }

  String _keyFromDate(DateTime d) => _progressService.keyFromDate(d);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Daily Schedule'),
      ),
      body: FutureBuilder<List<_DayPlan>>(
        future: _schedule,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: scheme.primary));
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: scheme.error, size: 40),
                  const SizedBox(height: 10),
                  const Text('Не удалось загрузить расписание'),
                  TextButton(
                    onPressed: () => setState(() => _schedule = _loadSchedule()),
                    child: const Text('Повторить'),
                  )
                ],
              ),
            );
          }

          final days = snapshot.data ?? [];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (uid != null) _dailyLogCard(context, uid),
              if (uid != null) const SizedBox(height: 12),
              if (uid != null)
                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: _progressService.completionStream(uid),
                  builder: (context, completionSnap) {
                    final completionMap = <String, bool>{};
                    if (completionSnap.hasData) {
                      for (final doc in completionSnap.data!.docs) {
                        completionMap[doc.id] = doc.data()['done'] == true;
                      }
                    }
                    return _calendarCard(
                      context,
                      completionMap,
                      onToggle: (date, done) => _toggleCompletion(uid, date, done),
                    );
                  },
                ),
              if (uid != null) const SizedBox(height: 12),
              ...days.map((day) => _dayCard(context, day)),
            ],
          );
        },
      ),
    );
  }

  Widget _calendarCard(
    BuildContext context,
    Map<String, bool> completionMap, {
    required Future<void> Function(DateTime date, bool done) onToggle,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final firstOfMonth = DateTime(_visibleMonth.year, _visibleMonth.month, 1);
    final firstWeekday = firstOfMonth.weekday; // Mon=1
    final daysInMonth = DateUtils.getDaysInMonth(_visibleMonth.year, _visibleMonth.month);
    final leadingEmpty = firstWeekday - 1;
    final cells = leadingEmpty + daysInMonth;
    final rows = (cells / 7).ceil();
    final totalCells = rows * 7;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.6),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.22)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                _monthLabel(_visibleMonth),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {
                  setState(() {
                    _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month - 1, 1);
                  });
                },
                icon: const Icon(Icons.chevron_left_rounded),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + 1, 1);
                  });
                },
                icon: const Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: const [
              _W('M'),
              _W('T'),
              _W('W'),
              _W('T'),
              _W('F'),
              _W('S'),
              _W('S'),
            ],
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: totalCells,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
            ),
            itemBuilder: (context, index) {
              final dayNum = index - leadingEmpty + 1;
              if (dayNum < 1 || dayNum > daysInMonth) {
                return const SizedBox.shrink();
              }
              final day = DateTime(_visibleMonth.year, _visibleMonth.month, dayNum);
              final key = _keyFromDate(day);
              final done = completionMap[key] == true;
              final isToday = DateUtils.isSameDay(day, DateTime.now());

              return InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => onToggle(day, !done),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: done
                        ? const Color(0xFF1AEFFF).withValues(alpha: 0.22)
                        : scheme.surfaceContainerHigh.withValues(alpha: 0.45),
                    border: Border.all(
                      color: isToday
                          ? scheme.primary
                          : done
                              ? const Color(0xFF1AEFFF).withValues(alpha: 0.7)
                              : scheme.outline.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        '$dayNum',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: done ? const Color(0xFF9CF7FF) : null,
                        ),
                      ),
                      if (done)
                        const Positioned(
                          right: 2,
                          top: 2,
                          child: Icon(Icons.check_circle, size: 12, color: Color(0xFF1AEFFF)),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _dailyLogCard(BuildContext context, String uid) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.6),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Daily Log', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _field(context, _weightCtrl, 'Weight', suffix: 'kg')),
              const SizedBox(width: 8),
              Expanded(child: _field(context, _stepsCtrl, 'Steps')),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _field(context, _waterCtrl, 'Water cups')),
              const SizedBox(width: 8),
              Expanded(child: _field(context, _workoutCtrl, 'Workout min')),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _savingLog ? null : () => _saveDailyLog(uid),
              icon: _savingLog
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_rounded),
              label: Text(_savingLog ? 'Saving...' : 'Save Daily Log'),
            ),
          )
        ],
      ),
    );
  }

  Widget _field(BuildContext context, TextEditingController ctrl, String label, {String? suffix}) {
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
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outline.withValues(alpha: 0.3)),
        ),
      ),
    );
  }

  String _monthLabel(DateTime d) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[d.month - 1]} ${d.year}';
  }

  Widget _dayCard(BuildContext context, _DayPlan day) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.6),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.22)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
          iconColor: scheme.primary,
          collapsedIconColor: scheme.primary,
          title: Text(day.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          leading: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: scheme.primary.withValues(alpha: 0.16),
            ),
            child: Icon(Icons.calendar_today_rounded, size: 18, color: scheme.primary),
          ),
          children: day.items
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Icon(Icons.fiber_manual_record,
                            size: 9, color: scheme.primary.withValues(alpha: 0.9)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item,
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.35,
                            color: scheme.onSurface.withValues(alpha: 0.88),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _W extends StatelessWidget {
  final String v;
  const _W(this.v);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          v,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
          ),
        ),
      ),
    );
  }
}

class _DayPlan {
  final String title;
  final List<String> items;
  _DayPlan({required this.title, required this.items});
}
