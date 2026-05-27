import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TrackProgressScreen extends StatefulWidget {
  final String weightKg;
  final int steps;
  final int stepsGoal;
  final int waterCups;
  final int waterGoal;
  final int workoutMinutes;

  const TrackProgressScreen({
    super.key,
    required this.weightKg,
    this.steps = 2569,
    this.stepsGoal = 4000,
    this.waterCups = 5,
    this.waterGoal = 8,
    this.workoutMinutes = 24,
  });

  @override
  State<TrackProgressScreen> createState() => _TrackProgressScreenState();
}

class _TrackProgressScreenState extends State<TrackProgressScreen>
    with TickerProviderStateMixin {
  late final TabController _tabController;
  late final AnimationController _animController;
  late final Animation<double> _curve;
  late Future<_ProgressSnapshot> _progressFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    );
    _curve = CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic);
    _animController.forward();
    _progressFuture = _loadProgressData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<_ProgressSnapshot> _loadProgressData() async {
    final prefs = await SharedPreferences.getInstance();
    final localWeight = prefs.getString('user_weight') ?? widget.weightKg;
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return _ProgressSnapshot(
        weightKg: localWeight,
        steps: widget.steps,
        stepsGoal: widget.stepsGoal,
        waterCups: widget.waterCups,
        waterGoal: widget.waterGoal,
        workoutMinutes: widget.workoutMinutes,
        weeklyWorkoutMinutes: const [12, 34, 44, 27, 23, 38, 8],
        weightHistoryKg: _weightFallback(localWeight),
      );
    }

    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final userData = userDoc.data() ?? <String, dynamic>{};
      final weight = (userData['weight']?.toString().trim().isNotEmpty ?? false)
          ? userData['weight'].toString().trim()
          : localWeight;

      final entriesSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('progress_entries')
          .orderBy('date', descending: true)
          .limit(30)
          .get();

      if (entriesSnap.docs.isEmpty) {
        return _ProgressSnapshot(
          weightKg: weight,
          steps: widget.steps,
          stepsGoal: widget.stepsGoal,
          waterCups: widget.waterCups,
          waterGoal: widget.waterGoal,
          workoutMinutes: widget.workoutMinutes,
          weeklyWorkoutMinutes: const [12, 34, 44, 27, 23, 38, 8],
          weightHistoryKg: _weightFallback(weight),
        );
      }

      final docs = entriesSnap.docs;
      final latest = docs.first.data();

      final latestSteps = _readInt(latest['steps'], widget.steps);
      final latestStepsGoal = _readInt(latest['stepsGoal'], widget.stepsGoal);
      final latestWater = _readInt(latest['waterCups'], widget.waterCups);
      final latestWaterGoal = _readInt(latest['waterGoal'], widget.waterGoal);
      final latestWorkout = _readInt(latest['workoutMinutes'], widget.workoutMinutes);

      final dailyByDate = <String, int>{};
      final weightPoints = <double>[];

      for (final doc in docs) {
        final data = doc.data();
        final ts = data['date'];
        final dt = ts is Timestamp ? ts.toDate() : DateTime.now();
        final key = '${dt.year}-${dt.month}-${dt.day}';
        final workout = _readInt(data['workoutMinutes'], 0);
        dailyByDate[key] = (dailyByDate[key] ?? 0) + workout;

        final parsedWeight = double.tryParse(data['weightKg']?.toString() ?? '');
        if (parsedWeight != null) {
          weightPoints.add(parsedWeight);
        }
      }

      final week = List<int>.filled(7, 0);
      for (var i = 0; i < 7; i++) {
        final d = DateTime.now().subtract(Duration(days: 6 - i));
        final key = '${d.year}-${d.month}-${d.day}';
        week[i] = dailyByDate[key] ?? 0;
      }

      final weightHistory = weightPoints.reversed.take(8).toList();
      if (weightHistory.isEmpty) {
        weightHistory.addAll(_weightFallback(weight));
      }

      return _ProgressSnapshot(
        weightKg: weight,
        steps: latestSteps,
        stepsGoal: latestStepsGoal <= 0 ? widget.stepsGoal : latestStepsGoal,
        waterCups: latestWater,
        waterGoal: latestWaterGoal <= 0 ? widget.waterGoal : latestWaterGoal,
        workoutMinutes: latestWorkout,
        weeklyWorkoutMinutes: week,
        weightHistoryKg: weightHistory,
      );
    } catch (_) {
      return _ProgressSnapshot(
        weightKg: localWeight,
        steps: widget.steps,
        stepsGoal: widget.stepsGoal,
        waterCups: widget.waterCups,
        waterGoal: widget.waterGoal,
        workoutMinutes: widget.workoutMinutes,
        weeklyWorkoutMinutes: const [12, 34, 44, 27, 23, 38, 8],
        weightHistoryKg: _weightFallback(localWeight),
      );
    }
  }

  static int _readInt(dynamic value, int fallback) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  static List<double> _weightFallback(String weight) {
    final base = double.tryParse(weight) ?? 80;
    return [base + 1.2, base + 0.9, base + 0.8, base + 0.6, base + 0.5, base + 0.3, base + 0.1, base];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Track Progress')),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              scheme.surface,
              scheme.surfaceContainerLowest,
              scheme.surface,
            ],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _NeonTabBar(controller: _tabController),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: FutureBuilder<_ProgressSnapshot>(
                future: _progressFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final data = snapshot.data ??
                      _ProgressSnapshot(
                        weightKg: widget.weightKg,
                        steps: widget.steps,
                        stepsGoal: widget.stepsGoal,
                        waterCups: widget.waterCups,
                        waterGoal: widget.waterGoal,
                        workoutMinutes: widget.workoutMinutes,
                        weeklyWorkoutMinutes: const [12, 34, 44, 27, 23, 38, 8],
                        weightHistoryKg: _weightFallback(widget.weightKg),
                      );

                  return TabBarView(
                    controller: _tabController,
                    children: [
                      _ProgressTab(
                        anim: _curve,
                        weightKg: data.weightKg,
                        steps: data.steps,
                        stepsGoal: data.stepsGoal,
                        waterCups: data.waterCups,
                        waterGoal: data.waterGoal,
                        workoutMinutes: data.workoutMinutes,
                        weeklyWorkoutMinutes: data.weeklyWorkoutMinutes,
                        weightHistoryKg: data.weightHistoryKg,
                      ),
                      const _SimpleStateTab(
                        title: 'Calendar',
                        subtitle: 'Weekly and monthly history will appear here.',
                        icon: Icons.calendar_month_rounded,
                      ),
                      const _SimpleStateTab(
                        title: 'Data',
                        subtitle: 'Detailed analytics and export options are coming next.',
                        icon: Icons.query_stats_rounded,
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NeonTabBar extends StatelessWidget {
  final TabController controller;

  const _NeonTabBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.25)),
      ),
      child: TabBar(
        controller: controller,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(
            colors: [scheme.primary.withValues(alpha: 0.9), const Color(0xFF1AEFFF)],
          ),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: scheme.onSurface.withValues(alpha: 0.72),
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: 'Daily'),
          Tab(text: 'Calendar'),
          Tab(text: 'Data'),
        ],
      ),
    );
  }
}

class _ProgressTab extends StatelessWidget {
  final Animation<double> anim;
  final String weightKg;
  final int steps;
  final int stepsGoal;
  final int waterCups;
  final int waterGoal;
  final int workoutMinutes;
  final List<int> weeklyWorkoutMinutes;
  final List<double> weightHistoryKg;

  const _ProgressTab({
    required this.anim,
    required this.weightKg,
    required this.steps,
    required this.stepsGoal,
    required this.waterCups,
    required this.waterGoal,
    required this.workoutMinutes,
    required this.weeklyWorkoutMinutes,
    required this.weightHistoryKg,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return AnimatedBuilder(
      animation: anim,
      builder: (context, _) {
        return Opacity(
          opacity: anim.value,
          child: Transform.translate(
            offset: Offset(0, 16 * (1 - anim.value)),
            child: ListView(
              padding: const EdgeInsets.all(18),
              children: [
                _NeonPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Weight',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: scheme.onSurface.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            weightKg,
                            style: theme.textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              'kg',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: scheme.onSurface.withValues(alpha: 0.78),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _WeightLineMock(progress: anim.value, values: weightHistoryKg),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _NeonPanel(
                        child: _CircularProgressStat(
                          title: 'Steps',
                          valueText: '$steps',
                          subtitle: '/$stepsGoal',
                          progress: (steps / stepsGoal) * anim.value,
                          color: const Color(0xFFB2FF2A),
                          icon: Icons.directions_walk_rounded,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _NeonPanel(
                        child: _CircularProgressStat(
                          title: 'Water',
                          valueText: '$waterCups',
                          subtitle: '/$waterGoal cups',
                          progress: (waterCups / waterGoal) * anim.value,
                          color: const Color(0xFF4B8DFF),
                          icon: Icons.water_drop_rounded,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _NeonPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Workout',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            '$workoutMinutes min',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _WeekBars(progress: anim.value, values: weeklyWorkoutMinutes),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SimpleStateTab extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _SimpleStateTab({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHigh.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: scheme.primary.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 42, color: scheme.primary),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: scheme.onSurface.withValues(alpha: 0.75)),
            ),
          ],
        ),
      ),
    );
  }
}

class _NeonPanel extends StatelessWidget {
  final Widget child;

  const _NeonPanel({required this.child});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: [
            scheme.surfaceContainerHighest.withValues(alpha: 0.66),
            scheme.surfaceContainerHigh.withValues(alpha: 0.42),
          ],
        ),
        border: Border.all(
          color: scheme.primary.withValues(alpha: 0.42),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.14),
            blurRadius: 24,
            spreadRadius: -5,
          ),
        ],
      ),
      child: child,
    );
  }
}

class _CircularProgressStat extends StatelessWidget {
  final String title;
  final String valueText;
  final String subtitle;
  final double progress;
  final Color color;
  final IconData icon;

  const _CircularProgressStat({
    required this.title,
    required this.valueText,
    required this.subtitle,
    required this.progress,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final value = progress.clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 6),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 10),
        Center(
          child: SizedBox(
            width: 112,
            height: 112,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: 1,
                  strokeWidth: 10,
                  color: color.withValues(alpha: 0.18),
                ),
                CircularProgressIndicator(
                  value: value,
                  strokeWidth: 10,
                  color: color,
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      valueText,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.72),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _WeightLineMock extends StatelessWidget {
  final double progress;
  final List<double> values;

  const _WeightLineMock({required this.progress, required this.values});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 120,
      child: CustomPaint(
        painter: _WeightLinePainter(
          lineColor: scheme.primary,
          gridColor: scheme.outline.withValues(alpha: 0.25),
          progress: progress,
          values: values,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _WeightLinePainter extends CustomPainter {
  final Color lineColor;
  final Color gridColor;
  final double progress;
  final List<double> values;

  _WeightLinePainter({
    required this.lineColor,
    required this.gridColor,
    required this.progress,
    required this.values,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    final linePaint = Paint()
      ..shader = LinearGradient(
        colors: [lineColor, const Color(0xFF1AEFFF)],
      ).createShader(Offset.zero & size)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    for (var i = 1; i < 5; i++) {
      final y = size.height * i / 5;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final normalized = _normalize(values);
    final points = <Offset>[];
    final count = normalized.length;
    for (var i = 0; i < count; i++) {
      final x = count == 1 ? 0.0 : size.width * (i / (count - 1));
      final y = size.height * (0.12 + normalized[i] * 0.74);
      points.add(Offset(x, y));
    }

    final animatedCount = (points.length * progress).ceil().clamp(2, points.length);
    final visible = points.take(animatedCount).toList();

    final path = Path()..moveTo(visible.first.dx, visible.first.dy);
    for (var i = 1; i < visible.length; i++) {
      path.quadraticBezierTo(
        (visible[i - 1].dx + visible[i].dx) / 2,
        visible[i - 1].dy,
        visible[i].dx,
        visible[i].dy,
      );
    }
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _WeightLinePainter oldDelegate) {
    return oldDelegate.lineColor != lineColor ||
        oldDelegate.gridColor != gridColor ||
        oldDelegate.progress != progress ||
        oldDelegate.values != values;
  }

  List<double> _normalize(List<double> input) {
    if (input.length < 2) return const [0.5, 0.5];
    final min = input.reduce((a, b) => a < b ? a : b);
    final max = input.reduce((a, b) => a > b ? a : b);
    final diff = max - min;
    if (diff == 0) {
      return List<double>.filled(input.length, 0.5);
    }
    return input.map((e) => (e - min) / diff).toList();
  }
}

class _WeekBars extends StatelessWidget {
  final double progress;
  final List<int> values;

  const _WeekBars({required this.progress, required this.values});

  @override
  Widget build(BuildContext context) {
    final labels = <String>['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    final bars = _normalized(values);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(bars.length, (i) {
        final selected = i == 5;
        return Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              width: 15,
              height: (72 * bars[i]) * progress,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: selected
                      ? const [Color(0xFFFF5722), Color(0xFFFF7043)]
                      : const [Color(0xFFFF3D00), Color(0xFFFFAB40)],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              labels[i],
              style: TextStyle(
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            )
          ],
        );
      }),
    );
  }

  List<double> _normalized(List<int> source) {
    if (source.length < 7) {
      return const [0.18, 0.52, 0.68, 0.44, 0.4, 0.58, 0.12];
    }
    final max = source.reduce((a, b) => a > b ? a : b);
    if (max <= 0) {
      return const [0.18, 0.52, 0.68, 0.44, 0.4, 0.58, 0.12];
    }
    return source.map((e) {
      final ratio = e / max;
      return (0.1 + (ratio * 0.9)).clamp(0.1, 1.0);
    }).toList();
  }
}

class _ProgressSnapshot {
  final String weightKg;
  final int steps;
  final int stepsGoal;
  final int waterCups;
  final int waterGoal;
  final int workoutMinutes;
  final List<int> weeklyWorkoutMinutes;
  final List<double> weightHistoryKg;

  _ProgressSnapshot({
    required this.weightKg,
    required this.steps,
    required this.stepsGoal,
    required this.waterCups,
    required this.waterGoal,
    required this.workoutMinutes,
    required this.weeklyWorkoutMinutes,
    required this.weightHistoryKg,
  });
}
