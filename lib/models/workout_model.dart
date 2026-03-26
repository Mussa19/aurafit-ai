class WorkoutExercise {
  final String name;
  final int sets;
  final String reps; 
  final bool isCompleted;

  WorkoutExercise({
    required this.name,
    required this.sets,
    required this.reps,
    this.isCompleted = false,
  });

  // 🔄 Create a new version of the exercise (e.g., when checking the 'completed' box)
  WorkoutExercise copyWith({
    String? name,
    int? sets,
    String? reps,
    bool? isCompleted,
  }) {
    return WorkoutExercise(
      name: name ?? this.name,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  // 📥 From JSON (For AI generation)
  factory WorkoutExercise.fromJson(Map<String, dynamic> json) {
    return WorkoutExercise(
      name: json['name'] ?? 'Exercise',
      sets: (json['sets'] ?? 0).toInt(),
      reps: json['reps']?.toString() ?? '0',
      isCompleted: json['isCompleted'] ?? false,
    );
  }

  // 📤 To JSON (For saving to database)
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'sets': sets,
      'reps': reps,
      'isCompleted': isCompleted,
    };
  }
}