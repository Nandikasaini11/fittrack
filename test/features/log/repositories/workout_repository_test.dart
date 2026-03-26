import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fittrack/features/log/repositories/workout_repository.dart';
import 'package:fittrack/features/log/models/workout_entry.dart';
import 'package:fittrack/shared/services/storage_service.dart';

class MockStorageService extends Mock implements StorageService {}

void main() {
  late WorkoutRepository repository;
  late MockStorageService mockStorage;

  setUpAll(() {
    registerFallbackValue(WorkoutEntry(
      id: '0',
      exerciseName: 'Fallback',
      sets: 0,
      reps: 0,
      date: DateTime.now(),
    ));
  });

  setUp(() {
    mockStorage = MockStorageService();
    repository = WorkoutRepository(mockStorage);
  });

  group('WorkoutRepository', () {
    final testEntry = WorkoutEntry(
      id: '1',
      exerciseName: 'Bench Press',
      sets: 3,
      reps: 10,
      date: DateTime.now(),
    );

    test('getAllEntries returns list of entries from storage', () async {
      when(() => mockStorage.getWorkoutEntries()).thenReturn([testEntry]);

      final result = await repository.getAllEntries();

      expect(result, [testEntry]);
      verify(() => mockStorage.getWorkoutEntries()).called(1);
    });

    test('addEntry calls storage to save workout', () async {
      when(() => mockStorage.addWorkoutEntry(any())).thenAnswer((_) async {});

      await repository.addEntry(testEntry);

      verify(() => mockStorage.addWorkoutEntry(testEntry)).called(1);
    });

    test('deleteEntry calls storage to delete workout', () async {
      when(() => mockStorage.deleteWorkoutEntry(any())).thenAnswer((_) async {});

      await repository.deleteEntry('1');

      verify(() => mockStorage.deleteWorkoutEntry('1')).called(1);
    });

    test('getStreak returns correct value from storage', () {
      when(() => mockStorage.calculateStreak()).thenReturn(5);

      final result = repository.getStreak();

      expect(result, 5);
      verify(() => mockStorage.calculateStreak()).called(1);
    });
  });
}

class WorkoutEntryFake extends Fake implements WorkoutEntry {}

void setupMocks() {
  registerFallbackValue(WorkoutEntry(exerciseName: '', sets: 0, reps: 0));
}
