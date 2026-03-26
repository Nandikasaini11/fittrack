import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/workout_entry.dart';
import '../repositories/workout_repository.dart';
import '../../../shared/services/storage_service.dart';

part 'workout_provider.g.dart';

// UPGRADED: Repository Provider for decoupling
@riverpod
WorkoutRepository workoutRepository(WorkoutRepositoryRef ref) {
  return WorkoutRepository(StorageService());
}

// UPGRADED: Migrated to AsyncNotifier for standard loading/error states
@riverpod
class WorkoutNotifier extends _$WorkoutNotifier {
  @override
  Future<List<WorkoutEntry>> build() async {
    return ref.read(workoutRepositoryProvider).getAllEntries();
  }

  Future<void> addEntry({
    required String name,
    required int sets,
    required int reps,
    double? weight,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final entry = WorkoutEntry(
        exerciseName: name,
        sets: sets,
        reps: reps,
        weightKg: weight,
      );
      await ref.read(workoutRepositoryProvider).addEntry(entry);
      final currentList = await ref.read(workoutRepositoryProvider).getAllEntries(); // Using repo as source of truth
      return [...currentList]; 
    });
    // UPGRADED: Refreshing state after mutation
    ref.invalidateSelf();
  }

  Future<void> deleteEntry(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(workoutRepositoryProvider).deleteEntry(id);
      final currentList = await ref.read(workoutRepositoryProvider).getAllEntries();
      return currentList;
    });
    ref.invalidateSelf();
  }
}
// UPGRADED: Helper extension for cleaner UI access
extension WorkoutNotifierX on AsyncValue<List<WorkoutEntry>> {
  List<WorkoutEntry> get todayEntries {
    final now = DateTime.now();
    return valueOrNull?.where((e) =>
      e.date.year == now.year &&
      e.date.month == now.month &&
      e.date.day == now.day
    ).toList() ?? [];
  }
}
