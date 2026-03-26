import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../log/providers/workout_provider.dart';
import '../../log/models/workout_entry.dart';

part 'progress_provider.g.dart';

@riverpod
class ProgressNotifier extends _$ProgressNotifier {
  @override
  void build() {}

  double getDailyVolume(DateTime date, List<WorkoutEntry> entries) {
    return entries
        .where((e) => e.date.year == date.year && e.date.month == date.month && e.date.day == date.day)
        .fold(0.0, (sum, e) => sum + (e.sets * e.reps * (e.weightKg ?? 1.0))); // Default to 1kg if weight is null
  }

  Map<String, double> getPersonalRecords(List<WorkoutEntry> entries) {
    final prs = <String, double>{};
    for (var entry in entries) {
      if (entry.weightKg != null) {
        if (!prs.containsKey(entry.exerciseName) || entry.weightKg! > prs[entry.exerciseName]!) {
          prs[entry.exerciseName] = entry.weightKg!;
        }
      }
    }
    return prs;
  }

  int getWeeklyStreak(List<WorkoutEntry> entries) {
    final now = DateTime.now();
    int streak = 0;
    for (int i = 0; i < 7; i++) {
        final date = now.subtract(Duration(days: i));
        final hasWorkout = entries.any((e) => e.date.year == date.year && e.date.month == date.month && e.date.day == date.day);
        if (hasWorkout) streak++;
    }
    return streak;
  }
}
