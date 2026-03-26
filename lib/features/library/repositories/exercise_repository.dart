import '../models/exercise_model.dart';
import '../../../shared/services/api_service.dart';
import '../../../core/errors/app_exception.dart';
import 'package:dio/dio.dart';

class ExerciseRepository {
  final ApiService _apiService;

  ExerciseRepository(this._apiService);

  Future<List<Exercise>> getExercises({int offset = 0, int limit = 20}) async {
    try {
      // UPGRADED: Added basic pagination support at repository level
      final allExercises = await _apiService.getExercises();
      final end = (offset + limit) > allExercises.length ? allExercises.length : (offset + limit);
      if (offset >= allExercises.length) return [];
      return allExercises.sublist(offset, end);
    } on DioException catch (e) {
      throw NetworkException('Network error while fetching exercises: ${e.message}', code: 'NETWORK_FETCH_ERROR');
    } catch (e) {
      throw ParseException('Failed to parse exercise data: $e', code: 'PARSE_ERROR');
    }
  }

  Future<List<Exercise>> searchExercises(String query) async {
    try {
      final allExercises = await _apiService.getExercises();
      return allExercises.where((e) => e.name.toLowerCase().contains(query.toLowerCase())).toList();
    } catch (e) {
      throw UnknownException('Search failed: $e', code: 'SEARCH_ERROR');
    }
  }
}
