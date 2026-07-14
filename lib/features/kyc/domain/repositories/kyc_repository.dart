import '../entities/kyc_entity.dart';

abstract class KycRepository {
  Future<KycStatusEntity> getStatus(String userId);

  Future<SendAadhaarOtpResultEntity> sendAadhaarOtp({
    required String userId,
    required String aadhaarNumber,
  });

  Future<VerifyAadhaarOtpResultEntity> verifyAadhaarOtp({
    required String userId,
    required String refId,
    required String otp,
    required String aadhaarNumber,
  });
}
