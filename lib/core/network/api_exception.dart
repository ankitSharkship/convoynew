import 'dart:io';

import 'package:dio/dio.dart';

class ApiException implements Exception {
  static const String genericMessage = 'Something went wrong';

  /// Shown instead of [genericMessage] whenever the failure is traced back
  /// to a connectivity problem (device offline, DNS failure, connection
  /// refused, or a request that never got a response in time) rather than
  /// a real server-side error. See [isConnectivityError] for the exact
  /// classification.
  static const String noConnectionMessage =
      'No internet connection — check your network and try again';

  final String message;
  final bool isConnectivityIssue;

  const ApiException([this.message = genericMessage])
    : isConnectivityIssue = false;

  const ApiException._connectivity()
    : message = noConnectionMessage,
      isConnectivityIssue = true;

  factory ApiException.fromDioException(DioException e) {
    if (isConnectivityError(e)) {
      return const ApiException._connectivity();
    }

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

  /// True when [e] represents a failure to reach the network at all —
  /// device offline, DNS lookup failure, connection refused, or a
  /// connect/send/receive timeout — as opposed to a real response from the
  /// server (even an error response like a 4xx/5xx, which proves the
  /// network itself is fine). Shared by [fromDioException] and the Dio
  /// client's interceptor (see `dio_client.dart`) so both use exactly one
  /// definition of "this was a connectivity problem".
  static bool isConnectivityError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return true;
      case DioExceptionType.unknown:
        return e.error is SocketException;
      case DioExceptionType.badCertificate:
      case DioExceptionType.badResponse:
      case DioExceptionType.cancel:
        return false;
      case DioExceptionType.transformTimeout:
        return false;
    }
  }

  /// Centralized mapping from any caught error to a UI-safe message.
  /// Never surfaces raw exception/stack trace text to the user.
  static String messageFor(Object error) =>
      error is ApiException ? error.message : genericMessage;

  /// Lets a screen distinguish "no internet" from any other failure — e.g.
  /// to swap in a wifi-off icon instead of the generic error icon — without
  /// needing to know about [DioException] at all.
  static bool isConnectivityIssueFor(Object error) =>
      error is ApiException && error.isConnectivityIssue;

  @override
  String toString() => message;
}
