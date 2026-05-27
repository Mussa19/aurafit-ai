import 'package:cloud_firestore/cloud_firestore.dart';

class DailyLogInput {
  final DateTime date;
  final int steps;
  final int stepsGoal;
  final int waterCups;
  final int waterGoal;
  final int workoutMinutes;
  final double? weightKg;

  const DailyLogInput({
    required this.date,
    required this.steps,
    required this.stepsGoal,
    required this.waterCups,
    required this.waterGoal,
    required this.workoutMinutes,
    required this.weightKg,
  });
}

class ProgressService {
  final FirebaseFirestore _db;
  ProgressService({FirebaseFirestore? firestore}) : _db = firestore ?? FirebaseFirestore.instance;

  String keyFromDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Stream<QuerySnapshot<Map<String, dynamic>>> completionStream(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('workout_completions')
        .orderBy('date', descending: true)
        .limit(180)
        .snapshots();
  }

  Future<void> toggleCompletion({
    required String uid,
    required DateTime day,
    required bool done,
    required DailyLogInput logDefaults,
  }) async {
    final normalized = DateTime(day.year, day.month, day.day);
    final key = keyFromDate(normalized);

    await _db.collection('users').doc(uid).collection('workout_completions').doc(key).set({
      'date': Timestamp.fromDate(normalized),
      'done': done,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await _db.collection('users').doc(uid).collection('progress_entries').doc(key).set({
      'date': Timestamp.fromDate(normalized),
      'steps': logDefaults.steps,
      'stepsGoal': logDefaults.stepsGoal,
      'waterCups': logDefaults.waterCups,
      'waterGoal': logDefaults.waterGoal,
      'workoutMinutes': done ? logDefaults.workoutMinutes : 0,
      if (logDefaults.weightKg != null) 'weightKg': logDefaults.weightKg,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> saveDailyLog({
    required String uid,
    required DailyLogInput input,
  }) async {
    final normalized = DateTime(input.date.year, input.date.month, input.date.day);
    final key = keyFromDate(normalized);

    await _db.collection('users').doc(uid).collection('progress_entries').doc(key).set({
      'date': Timestamp.fromDate(normalized),
      'steps': input.steps,
      'stepsGoal': input.stepsGoal,
      'waterCups': input.waterCups,
      'waterGoal': input.waterGoal,
      'workoutMinutes': input.workoutMinutes,
      if (input.weightKg != null) 'weightKg': input.weightKg,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await _db.collection('users').doc(uid).collection('workout_completions').doc(key).set({
      'date': Timestamp.fromDate(normalized),
      'done': input.workoutMinutes > 0,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}

