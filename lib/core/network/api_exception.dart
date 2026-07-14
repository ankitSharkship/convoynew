import 'package:dio/dio.dart';

class ApiException implements Exception {
  static const String genericMessage = 'Something went wrong';

  final String message;

  const ApiException([this.message = genericMessage]);

  factory ApiException.fromDioException(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      final errorMessage = data['error_message'];
      if (errorMessage is String && errorMessage.trim().isNotEmpty) {
        return ApiException(errorMessage);
      }

      final detail = data['detail'];
      if (detail is String && detail.trim().isNotEmpty) {
        return ApiException(detail);
      }
      if (detail is List && detail.isNotEmpty) {
        final first = detail.first;
        if (first is Map && first['msg'] is String) {
          return ApiException(first['msg'] as String);
        }
      }
    }
    return const ApiException();
  }

  /// Centralized mapping from any caught error to a UI-safe message.
  /// Never surfaces raw exception/stack trace text to the user.
  static String messageFor(Object error) =>
      error is ApiException ? error.message : genericMessage;

  @override
  String toString() => message;
}
