import '../entities/kyc_entity.dart';
import '../repositories/kyc_repository.dart';

class SendAadhaarOtpUseCase {
  final KycRepository _repository;

  SendAadhaarOtpUseCase(this._repository);

  Future<SendAadhaarOtpResultEntity> execute({
    required String userId,
    required String aadhaarNumber,
  }) =>
      _repository.sendAadhaarOtp(userId: userId, aadhaarNumber: aadhaarNumber);
}
