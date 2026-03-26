import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fittrack/shared/services/storage_service.dart';
import 'package:fittrack/features/log/models/workout_entry.dart';
import 'package:hive_flutter/hive_flutter.dart';

class MockBox extends Mock implements Box<WorkoutEntry> {}

void main() {
  late StorageService storageService;
  late MockBox mockBox;

  setUp(() {
    mockBox = MockBox();
    storageService = StorageService();
    storageService.workoutBox = mockBox;
  });

  group('Streak Calculation', () {
    test('calculateStreak returns 0 when no entries exist', () {
      when(() => mockBox.values).thenReturn([]);
      expect(storageService.calculateStreak(), 0);
    });

    test('calculateStreak returns 1 when only today has a workout', () {
      final today = DateTime.now();
      when(() => mockBox.values).thenReturn([
        WorkoutEntry(exerciseName: 'Test', sets: 1, reps: 1, date: today),
      ]);
      expect(storageService.calculateStreak(), 1);
    });

    test('calculateStreak returns 3 for consecutive days including today', () {
      final today = DateTime.now();
      when(() => mockBox.values).thenReturn([
        WorkoutEntry(exerciseName: 'T1', sets: 1, reps: 1, date: today),
        WorkoutEntry(exerciseName: 'T2', sets: 1, reps: 1, date: today.subtract(const Duration(days: 1))),
        WorkoutEntry(exerciseName: 'T3', sets: 1, reps: 1, date: today.subtract(const Duration(days: 2))),
      ]);
      expect(storageService.calculateStreak(), 3);
    });

    test('calculateStreak returns 0 if last workout was 2 days ago', () {
      final today = DateTime.now();
      when(() => mockBox.values).thenReturn([
        WorkoutEntry(exerciseName: 'Old', sets: 1, reps: 1, date: today.subtract(const Duration(days: 2))),
      ]);
      expect(storageService.calculateStreak(), 0);
    });

    test('calculateStreak handles multiple workouts on the same day', () {
      final today = DateTime.now();
      when(() => mockBox.values).thenReturn([
        WorkoutEntry(exerciseName: 'T1', sets: 1, reps: 1, date: today),
        WorkoutEntry(exerciseName: 'T2', sets: 1, reps: 1, date: today),
        WorkoutEntry(exerciseName: 'T3', sets: 1, reps: 1, date: today.subtract(const Duration(days: 1))),
      ]);
      expect(storageService.calculateStreak(), 2);
    });
  });
}
