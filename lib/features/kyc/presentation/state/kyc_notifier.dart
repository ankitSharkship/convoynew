import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../../../profile/presentation/state/profile_notifier.dart';
import '../../data/datasources/kyc_remote_datasource.dart';
import '../../data/repositories/kyc_repository_impl.dart';
import '../../domain/usecases/get_kyc_status_usecase.dart';
import '../../domain/usecases/send_aadhaar_otp_usecase.dart';
import '../../domain/usecases/verify_aadhaar_otp_usecase.dart';

part 'kyc_notifier.g.dart';

@riverpod
KycRemoteDataSource kycRemoteDataSource(KycRemoteDataSourceRef ref) {
  return KycRemoteDataSourceImpl(ref.watch(dioProvider));
}

@riverpod
KycRepositoryImpl kycRepository(KycRepositoryRef ref) {
  return KycRepositoryImpl(ref.watch(kycRemoteDataSourceProvider));
}

@riverpod
GetKycStatusUseCase getKycStatusUseCase(GetKycStatusUseCaseRef ref) {
  return GetKycStatusUseCase(ref.watch(kycRepositoryProvider));
}

@riverpod
SendAadhaarOtpUseCase sendAadhaarOtpUseCase(SendAadhaarOtpUseCaseRef ref) {
  return SendAadhaarOtpUseCase(ref.watch(kycRepositoryProvider));
}

@riverpod
VerifyAadhaarOtpUseCase verifyAadhaarOtpUseCase(
    VerifyAadhaarOtpUseCaseRef ref) {
  return VerifyAadhaarOtpUseCase(ref.watch(kycRepositoryProvider));
}

class KycState {
  final bool sendingOtp;
  final bool verifyingOtp;
  final String? error;
  final String? refId;
  final String? aadhaarNumber;
  final bool verified;

  const KycState({
    this.sendingOtp = false,
    this.verifyingOtp = false,
    this.error,
    this.refId,
    this.aadhaarNumber,
    this.verified = false,
  });

  KycState copyWith({
    bool? sendingOtp,
    bool? verifyingOtp,
    String? error,
    bool clearError = false,
    String? refId,
    String? aadhaarNumber,
    bool? verified,
  }) {
    return KycState(
      sendingOtp: sendingOtp ?? this.sendingOtp,
      verifyingOtp: verifyingOtp ?? this.verifyingOtp,
      error: clearError ? null : (error ?? this.error),
      refId: refId ?? this.refId,
      aadhaarNumber: aadhaarNumber ?? this.aadhaarNumber,
      verified: verified ?? this.verified,
    );
  }
}

@riverpod
class KycNotifier extends _$KycNotifier {
  @override
  KycState build() => const KycState();

  Future<bool> sendOtp(String aadhaarNumber) async {
    state = state.copyWith(sendingOtp: true, clearError: true);
    try {
      final userId = await ref.read(tokenStorageProvider).getUserId();
      if (userId == null) throw const ApiException();

      final result = await ref.read(sendAadhaarOtpUseCaseProvider).execute(
            userId: userId,
            aadhaarNumber: aadhaarNumber,
          );
      state = state.copyWith(
        sendingOtp: false,
        refId: result.refId,
        aadhaarNumber: aadhaarNumber,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        sendingOtp: false,
        error: ApiException.messageFor(e),
      );
      return false;
    }
  }

  Future<bool> verifyOtp(String otp) async {
    final refId = state.refId;
    final aadhaarNumber = state.aadhaarNumber;
    if (refId == null || aadhaarNumber == null) return false;

    state = state.copyWith(verifyingOtp: true, clearError: true);
    try {
      final userId = await ref.read(tokenStorageProvider).getUserId();
      if (userId == null) throw const ApiException();

      await ref.read(verifyAadhaarOtpUseCaseProvider).execute(
            userId: userId,
            refId: refId,
            otp: otp,
            aadhaarNumber: aadhaarNumber,
          );
      state = state.copyWith(verifyingOtp: false, verified: true);
      ref.invalidate(profileNotifierProvider);
      return true;
    } catch (e) {
      state = state.copyWith(
        verifyingOtp: false,
        error: ApiException.messageFor(e),
      );
      return false;
    }
  }

  void clearError() => state = state.copyWith(clearError: true);
}
