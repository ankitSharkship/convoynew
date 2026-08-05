import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/shared_preferences_provider.dart';
import '../../../profile/presentation/state/profile_notifier.dart';
import '../../data/datasources/kyc_local_datasource.dart';
import '../../data/datasources/kyc_remote_datasource.dart';
import '../../data/repositories/kyc_repository_impl.dart';
import '../../domain/exceptions/aadhaar_conflict_exception.dart';
import '../../domain/usecases/check_aadhaar_availability_usecase.dart';
import '../../domain/usecases/get_kyc_status_usecase.dart';
import '../../domain/usecases/send_aadhaar_otp_usecase.dart';
import '../../domain/usecases/verify_aadhaar_otp_usecase.dart';

part 'kyc_notifier.g.dart';

const _aadhaarCheckDebounce = Duration(milliseconds: 400);

@riverpod
KycRemoteDataSource kycRemoteDataSource(KycRemoteDataSourceRef ref) {
  return KycRemoteDataSourceImpl(ref.watch(dioProvider));
}

@riverpod
KycLocalDataSource kycLocalDataSource(KycLocalDataSourceRef ref) {
  return KycLocalDataSourceImpl(ref.watch(sharedPreferencesProvider));
}

@riverpod
KycRepositoryImpl kycRepository(KycRepositoryRef ref) {
  return KycRepositoryImpl(
    ref.watch(kycRemoteDataSourceProvider),
    ref.watch(kycLocalDataSourceProvider),
  );
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
  VerifyAadhaarOtpUseCaseRef ref,
) {
  return VerifyAadhaarOtpUseCase(ref.watch(kycRepositoryProvider));
}

@riverpod
CheckAadhaarAvailabilityUseCase checkAadhaarAvailabilityUseCase(
  CheckAadhaarAvailabilityUseCaseRef ref,
) {
  return CheckAadhaarAvailabilityUseCase(ref.watch(kycRepositoryProvider));
}

class KycState {
  final bool sendingOtp;
  final bool verifyingOtp;
  final String? error;
  final String? refId;
  final String? aadhaarNumber;
  final bool verified;

  /// Live `/aadhaar/check` lookup state — purely informational feedback
  /// while the user is still typing, never the actual gate (that's always
  /// `send-otp`, enforced server-side regardless of this).
  final bool checkingAadhaar;
  final bool? aadhaarAvailable;
  final String? aadhaarCheckMessage;

  /// Set when `verify` returns the race-condition 409 — the OTP was
  /// valid, but this Aadhaar lost a race with another account's
  /// verification. Distinct from [error] so the OTP screen can react by
  /// showing a snackbar and leaving the flow entirely, rather than
  /// leaving the user on the OTP screen to "retry" something that can
  /// never succeed.
  final bool aadhaarConflict;

  const KycState({
    this.sendingOtp = false,
    this.verifyingOtp = false,
    this.error,
    this.refId,
    this.aadhaarNumber,
    this.verified = false,
    this.checkingAadhaar = false,
    this.aadhaarAvailable,
    this.aadhaarCheckMessage,
    this.aadhaarConflict = false,
  });

  KycState copyWith({
    bool? sendingOtp,
    bool? verifyingOtp,
    String? error,
    bool clearError = false,
    String? refId,
    String? aadhaarNumber,
    bool? verified,
    bool? checkingAadhaar,
    bool? aadhaarAvailable,
    bool clearAadhaarAvailable = false,
    String? aadhaarCheckMessage,
    bool clearAadhaarCheckMessage = false,
    bool? aadhaarConflict,
  }) {
    return KycState(
      sendingOtp: sendingOtp ?? this.sendingOtp,
      verifyingOtp: verifyingOtp ?? this.verifyingOtp,
      error: clearError ? null : (error ?? this.error),
      refId: refId ?? this.refId,
      aadhaarNumber: aadhaarNumber ?? this.aadhaarNumber,
      verified: verified ?? this.verified,
      checkingAadhaar: checkingAadhaar ?? this.checkingAadhaar,
      aadhaarAvailable: clearAadhaarAvailable
          ? null
          : (aadhaarAvailable ?? this.aadhaarAvailable),
      aadhaarCheckMessage: clearAadhaarCheckMessage
          ? null
          : (aadhaarCheckMessage ?? this.aadhaarCheckMessage),
      aadhaarConflict: aadhaarConflict ?? this.aadhaarConflict,
    );
  }
}

@riverpod
class KycNotifier extends _$KycNotifier {
  Timer? _checkDebounce;
  int _checkRequestId = 0;

  @override
  KycState build() {
    ref.onDispose(() => _checkDebounce?.cancel());
    return const KycState();
  }

  Future<bool> sendOtp(String aadhaarNumber) async {
    state = state.copyWith(
      sendingOtp: true,
      clearError: true,
      aadhaarConflict: false,
    );
    try {
      final userId = await ref.read(tokenStorageProvider).getUserId();
      if (userId == null) throw const ApiException();

      final result = await ref
          .read(sendAadhaarOtpUseCaseProvider)
          .execute(userId: userId, aadhaarNumber: aadhaarNumber);
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

      await ref
          .read(verifyAadhaarOtpUseCaseProvider)
          .execute(
            userId: userId,
            refId: refId,
            otp: otp,
            aadhaarNumber: aadhaarNumber,
          );
      state = state.copyWith(verifyingOtp: false, verified: true);
      ref.invalidate(profileNotifierProvider);
      return true;
    } on AadhaarConflictException catch (e) {
      // The OTP was valid — this Aadhaar just lost a race with another
      // account's verification at the final commit. Nothing about
      // staying on the OTP screen helps here, so this is surfaced
      // through `aadhaarConflict` rather than `error`: the screen reacts
      // by showing a snackbar and leaving the flow entirely (see
      // `resetAfterConflict`), instead of inviting the user to retry.
      state = state.copyWith(
        verifyingOtp: false,
        error: e.message,
        aadhaarConflict: true,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        verifyingOtp: false,
        error: ApiException.messageFor(e),
      );
      return false;
    }
  }

  /// Pure lookup for live-typing feedback as the user finishes entering
  /// their Aadhaar number — debounced, and a no-op until there are
  /// exactly 12 digits. Never the actual gate: `sendOtp` enforces the
  /// identical check regardless, so a stale or skipped result here
  /// changes nothing about what's actually allowed.
  void checkAadhaarAvailability(String aadhaarNumber) {
    _checkDebounce?.cancel();
    if (aadhaarNumber.length != 12) {
      state = state.copyWith(
        checkingAadhaar: false,
        clearAadhaarAvailable: true,
        clearAadhaarCheckMessage: true,
      );
      return;
    }

    final requestId = ++_checkRequestId;
    state = state.copyWith(checkingAadhaar: true);
    _checkDebounce = Timer(_aadhaarCheckDebounce, () async {
      try {
        final userId = await ref.read(tokenStorageProvider).getUserId();
        if (userId == null) return;

        final result = await ref
            .read(checkAadhaarAvailabilityUseCaseProvider)
            .execute(userId: userId, aadhaarNumber: aadhaarNumber);
        if (requestId != _checkRequestId) return; // superseded, drop it

        state = state.copyWith(
          checkingAadhaar: false,
          aadhaarAvailable: result.available,
          aadhaarCheckMessage: result.message,
          clearAadhaarCheckMessage: result.message == null,
        );
      } catch (_) {
        // Pure UX sugar — a failed lookup (offline, server hiccup) isn't
        // worth surfacing to the user. `sendOtp` is the real gate and
        // will catch a genuine conflict when they actually submit.
        if (requestId != _checkRequestId) return;
        state = state.copyWith(
          checkingAadhaar: false,
          clearAadhaarAvailable: true,
          clearAadhaarCheckMessage: true,
        );
      }
    });
  }

  /// Clears the whole Aadhaar+OTP session after a conflict — the user
  /// must re-enter a different Aadhaar number from scratch.
  void resetAfterConflict() {
    _checkDebounce?.cancel();
    state = const KycState();
  }

  void clearError() => state = state.copyWith(clearError: true);
}
