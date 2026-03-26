import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'workout_entry.g.dart';

@HiveType(typeId: 0)
class WorkoutEntry extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String exerciseName;

  @HiveField(2)
  final int sets;

  @HiveField(3)
  final int reps;

  @HiveField(4)
  final double? weightKg;

  @HiveField(5)
  final DateTime date;

  WorkoutEntry({
    String? id,
    required this.exerciseName,
    required this.sets,
    required this.reps,
    this.weightKg,
    DateTime? date,
  })  : id = id ?? const Uuid().v4(),
        date = date ?? DateTime.now();

  WorkoutEntry copyWith({
    String? id,
    String? exerciseName,
    int? sets,
    int? reps,
    double? weightKg,
    DateTime? date,
  }) {
    return WorkoutEntry(
      id: id ?? this.id,
      exerciseName: exerciseName ?? this.exerciseName,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      weightKg: weightKg ?? this.weightKg,
      date: date ?? this.date,
    );
  }
}
