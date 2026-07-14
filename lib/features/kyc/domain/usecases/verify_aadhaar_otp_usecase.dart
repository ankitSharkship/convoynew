import '../entities/kyc_entity.dart';
import '../repositories/kyc_repository.dart';

class VerifyAadhaarOtpUseCase {
  final KycRepository _repository;

  VerifyAadhaarOtpUseCase(this._repository);

  Future<VerifyAadhaarOtpResultEntity> execute({
    required String userId,
    required String refId,
    required String otp,
    required String aadhaarNumber,
  }) => _repository.verifyAadhaarOtp(
    userId: userId,
    refId: refId,
    otp: otp,
    aadhaarNumber: aadhaarNumber,
  );
}
