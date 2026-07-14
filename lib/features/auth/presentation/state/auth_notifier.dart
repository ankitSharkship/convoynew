import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/router/app_router.dart';
import '../../data/datasources/auth_local_datasource.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/auth_session_entity.dart';
import '../../domain/usecases/send_otp_usecase.dart';
import '../../domain/usecases/verify_otp_usecase.dart';
import '../../../profile/presentation/state/profile_notifier.dart';

part 'auth_notifier.g.dart';

@riverpod
AuthRemoteDataSource authRemoteDataSource(AuthRemoteDataSourceRef ref) {
  return AuthRemoteDataSourceImpl(ref.watch(dioProvider));
}

@riverpod
AuthLocalDataSource authLocalDataSource(AuthLocalDataSourceRef ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final tokenStorage = ref.watch(tokenStorageProvider);
  return AuthLocalDataSourceImpl(prefs, tokenStorage);
}

@riverpod
AuthRepositoryImpl authRepository(AuthRepositoryRef ref) {
  return AuthRepositoryImpl(
    ref.watch(authRemoteDataSourceProvider),
    ref.watch(authLocalDataSourceProvider),
  );
}

@riverpod
SendOtpUseCase sendOtpUseCase(SendOtpUseCaseRef ref) {
  return SendOtpUseCase(ref.watch(authRepositoryProvider));
}

@riverpod
VerifyOtpUseCase verifyOtpUseCase(VerifyOtpUseCaseRef ref) {
  return VerifyOtpUseCase(ref.watch(authRepositoryProvider));
}

sealed class AuthState {
  const AuthState();
}

class AuthIdle extends AuthState {
  const AuthIdle();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthOtpSent extends AuthState {
  final String phone;
  const AuthOtpSent(this.phone);
}

class AuthSuccess extends AuthState {
  final AuthSessionEntity session;
  const AuthSuccess(this.session);
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
}

@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  AuthState build() => const AuthIdle();

  Future<void> sendOtp(String phone) async {
    state = const AuthLoading();
    try {
      final useCase = ref.read(sendOtpUseCaseProvider);
      await useCase.execute(phone);
      state = AuthOtpSent(phone);
    } catch (e) {
      state = AuthError(ApiException.messageFor(e));
    }
  }

  Future<void> verifyOtp(String phone, String otp) async {
    state = const AuthLoading();
    try {
      final useCase = ref.read(verifyOtpUseCaseProvider);
      final session = await useCase.execute(phone, otp);
      state = AuthSuccess(session);
    } catch (e) {
      state = AuthError(ApiException.messageFor(e));
    }
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    final profileLocal = ref.read(profileLocalDataSourceProvider);
    await profileLocal.clearProfile();
    await profileLocal.clearPhotoPath();
    ref.invalidate(profileNotifierProvider);
    state = const AuthIdle();
  }

  void reset() => state = const AuthIdle();
}
