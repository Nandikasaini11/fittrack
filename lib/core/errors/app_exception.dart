/// Custom application-level exception class for typed error handling.
abstract class AppException implements Exception {
  final String message;
  final String? code;

  AppException(this.message, {this.code});

  @override
  String toString() => '[$code] $message';
}

/// Thrown when a network-related error occurs.
class NetworkException extends AppException {
  NetworkException(super.message, {super.code});
}

/// Thrown when a storage-related error occurs (e.g., Hive interaction).
class StorageException extends AppException {
  StorageException(super.message, {super.code});
}

/// Thrown when data parsing fails (e.g., JSON to Model).
class ParseException extends AppException {
  ParseException(super.message, {super.code});
}

/// Thrown for generic or unknown application errors.
class UnknownException extends AppException {
  UnknownException(super.message, {super.code});
}
