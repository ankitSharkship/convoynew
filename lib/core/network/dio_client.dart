import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'api_exception.dart';
import 'auth_revocation_notifier.dart';
import 'network_status_provider.dart';
import 'token_storage.dart';

part 'dio_client.g.dart';

const _connectTimeout = Duration(seconds: 15);
const _sendTimeout = Duration(seconds: 15);
const _receiveTimeout = Duration(seconds: 15);

const _unauthenticatedPaths = ['/api/auth/send-otp', '/api/auth/verify-otp'];

final authRevocationNotifier = AuthRevocationNotifier();

@riverpod
TokenStorage tokenStorage(TokenStorageRef ref) {
  return TokenStorage(const FlutterSecureStorage());
}

@riverpod
Dio dio(DioRef ref) {
  final storage = ref.watch(tokenStorageProvider);
  // Captured once, like [storage] above, rather than doing `ref.read(...)`
  // inside the interceptor closures below — those run at arbitrary future
  // times (whenever a response/error comes back), and `dio` is an
  // autoDispose provider, so `ref` itself could be invalid by then even
  // though the (keepAlive) notifier it points to never is.
  final networkStatus = ref.read(networkStatusNotifierProvider.notifier);
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
      onResponse: (response, handler) {
        // Any response at all — even one we go on to treat as a business
        // error — proves the request reached the server, so the network
        // is up. This is what lets the offline banner clear itself as
        // soon as connectivity comes back, without polling.
        networkStatus.markOnline();
        handler.next(response);
      },
      onError: (error, handler) async {
        if (ApiException.isConnectivityError(error)) {
          networkStatus.markOffline();
        } else {
          // A bad-response/cancel/etc. error still means we talked to the
          // server, so connectivity itself is fine.
          networkStatus.markOnline();
        }

        // No refresh-token endpoint is available yet — until one exists,
        // a 401 clears the stored session so the app treats the user as
        // logged out instead of silently retrying with a dead token.
        // Login itself is unauthenticated, so a 401 there (e.g. a wrong/
        // expired OTP) must not clear an unrelated, still-valid session.
        final isUnauthenticatedEndpoint = _unauthenticatedPaths.any(
          (path) => error.requestOptions.path.contains(path),
        );
        if (error.response?.statusCode == 401 && !isUnauthenticatedEndpoint) {
          await storage.clear();
          authRevocationNotifier.revoke();
        }
        handler.next(error);
      },
    ),
  );
  return dio;
}
