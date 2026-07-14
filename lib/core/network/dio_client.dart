import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'token_storage.dart';

part 'dio_client.g.dart';

const _connectTimeout = Duration(seconds: 15);
const _sendTimeout = Duration(seconds: 15);
const _receiveTimeout = Duration(seconds: 15);

const _unauthenticatedPaths = [
  '/api/auth/send-otp',
  '/api/auth/verify-otp',
];

@riverpod
TokenStorage tokenStorage(TokenStorageRef ref) {
  return TokenStorage(const FlutterSecureStorage());
}

@riverpod
Dio dio(DioRef ref) {
  final storage = ref.watch(tokenStorageProvider);
  final dio = Dio(
    BaseOptions(
      baseUrl: dotenv.env['API_BASE_URL'] ?? '',
      connectTimeout: _connectTimeout,
      sendTimeout: _sendTimeout,
      receiveTimeout: _receiveTimeout,
    ),
  );
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await storage.getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        // No refresh-token endpoint is available yet — until one exists,
        // a 401 clears the stored session so the app treats the user as
        // logged out instead of silently retrying with a dead token.
        // Login itself is unauthenticated, so a 401 there (e.g. a wrong/
        // expired OTP) must not clear an unrelated, still-valid session.
        final isUnauthenticatedEndpoint = _unauthenticatedPaths
            .any((path) => error.requestOptions.path.contains(path));
        if (error.response?.statusCode == 401 && !isUnauthenticatedEndpoint) {
          await storage.clear();
        }
        handler.next(error);
      },
    ),
  );
  return dio;
}
