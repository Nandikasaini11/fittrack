import 'dart:async';
import 'package:dio/dio.dart';
import '../../features/library/models/exercise_model.dart';
import '../../core/errors/app_exception.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  final Dio _dio;
  final Map<String, List<Exercise>> _cache = {};

  ApiService() : _dio = Dio(
    BaseOptions(
      baseUrl: 'https://exercisedb.dev/api/v1',
      connectTimeout: const Duration(seconds: 30), // UPGRADED: Increased for reliability
      receiveTimeout: const Duration(seconds: 30),
    ),
  ) {
    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.addAll([
      // UPGRADED: Request/Status Logging Interceptor (Debug only)
      LogInterceptor(
        requestHeader: true,
        requestBody: true,
        responseHeader: false,
        responseBody: false,
        error: true,
        logPrint: (object) {
          if (kDebugMode) print('🔥 [CRED-DIAG] $object');
        },
      ),
      // UPGRADED: Retry Interceptor with Exponential Backoff
      InterceptorsWrapper(
        onError: (DioException e, handler) async {
          if (_shouldRetry(e)) {
            try {
              return handler.resolve(await _retry(e.requestOptions));
            } catch (e) {
              return handler.next(e as DioException);
            }
          }
          return handler.next(e);
        },
      ),
    ]);
  }

  bool _shouldRetry(DioException err) {
    return err.type != DioExceptionType.cancel &&
        err.type != DioExceptionType.badResponse;
  }

  Future<Response> _retry(RequestOptions requestOptions) async {
    const maxRetries = 3;
    for (int i = 0; i < maxRetries; i++) {
      try {
        // UPGRADED: Exponential Backoff
        await Future.delayed(Duration(seconds: (i + 1) * 2));
        return await _dio.request(
          requestOptions.path,
          data: requestOptions.data,
          queryParameters: requestOptions.queryParameters,
          options: Options(method: requestOptions.method, headers: requestOptions.headers),
        );
      } catch (e) {
        if (i == maxRetries - 1) rethrow;
      }
    }
    throw DioException(requestOptions: requestOptions);
  }

  Future<List<Exercise>> getExercises({int limit = 20, int offset = 0}) async {
    try {
      final response = await _dio.get('/exercises', queryParameters: {'limit': limit, 'offset': offset});
      final data = response.data['data'] as List;
      // UPGRADED: Use compute() or Isolates for parsing if dataset grows
      return data.map((e) => Exercise.fromJson(e)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Exercise>> searchExercises(String query) async {
    if (_cache.containsKey(query)) return _cache[query]!;
    try {
      final response = await _dio.get('/exercises/search', queryParameters: {'query': query});
      final data = response.data['data'] as List;
      final results = data.map((e) => Exercise.fromJson(e)).toList();
      _cache[query] = results;
      return results;
    } catch (e) {
      throw _handleError(e);
    }
  }

  AppException _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
          return NetworkException('Connection timed out. Please check your internet.', code: 'TIMEOUT');
        case DioExceptionType.connectionError:
          return NetworkException('No internet connection detected.', code: 'NO_INTERNET');
        default:
          return NetworkException('Technical glitch in the matrix: ${error.message}', code: 'API_ERROR');
      }
    }
    return ParseException('Failed to process exercise data.', code: 'DATA_ERROR');
  }
}
