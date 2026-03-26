import '../models/workout_entry.dart';
import '../../../shared/services/storage_service.dart';
import '../../../core/errors/app_exception.dart';

class WorkoutRepository {
  final StorageService _storageService;

  WorkoutRepository(this._storageService);

  Future<List<WorkoutEntry>> getAllEntries() async {
    try {
      return _storageService.getWorkoutEntries();
    } catch (e) {
      throw StorageException('Failed to fetch workout entries: $e', code: 'STORAGE_FETCH_ERROR');
    }
  }

  Future<void> addEntry(WorkoutEntry entry) async {
    try {
      await _storageService.addWorkoutEntry(entry);
    } catch (e) {
      throw StorageException('Failed to save workout entry: $e', code: 'STORAGE_SAVE_ERROR');
    }
  }

  Future<void> deleteEntry(String id) async {
    try {
      await _storageService.deleteWorkoutEntry(id);
    } catch (e) {
      throw StorageException('Failed to delete workout entry: $id', code: 'STORAGE_DELETE_ERROR');
    }
  }

  int getStreak() {
    return _storageService.calculateStreak();
  }
}
