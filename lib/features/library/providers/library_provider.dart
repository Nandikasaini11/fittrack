import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/exercise_model.dart';
import '../repositories/exercise_repository.dart';
import '../../../shared/services/api_service.dart';

part 'library_provider.g.dart';

@riverpod
ExerciseRepository exerciseRepository(ExerciseRepositoryRef ref) {
  return ExerciseRepository(ApiService());
}

@riverpod
class LibraryNotifier extends _$LibraryNotifier {
  int _currentOffset = 0;
  final int _limit = 20;
  bool _hasMore = true;

  @override
  Future<List<Exercise>> build() async {
    _currentOffset = 0;
    _hasMore = true;
    return ref.read(exerciseRepositoryProvider).getExercises(offset: 0, limit: _limit);
  }

  Future<void> fetchNextPage() async {
    if (!_hasMore || state.isLoading) return;

    final previousState = state.valueOrNull ?? [];
    state = const AsyncValue.loading();
    
    state = await AsyncValue.guard(() async {
      _currentOffset += _limit;
      final newItems = await ref.read(exerciseRepositoryProvider).getExercises(
        offset: _currentOffset,
        limit: _limit,
      );
      
      if (newItems.length < _limit) {
        _hasMore = false;
      }
      
      return [...previousState, ...newItems];
    });
  }

  Future<void> search(String query) async {
    if (query.isEmpty) {
      ref.invalidateSelf();
      return;
    }
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(exerciseRepositoryProvider).searchExercises(query));
  }
}
