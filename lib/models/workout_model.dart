class WorkoutExercise {
  final String name;
  final int sets;
  final String reps; // Using String because reps can be "12" or "60 sec"
  final bool isCompleted;

  WorkoutExercise({
    required this.name,
    required this.sets,
    required this.reps,
    this.isCompleted = false,
  });
}