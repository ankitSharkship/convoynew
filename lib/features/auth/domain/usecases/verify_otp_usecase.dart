import '../entities/auth_session_entity.dart';
import '../repositories/auth_repository.dart';

class VerifyOtpUseCase {
  final AuthRepository _repository;

  VerifyOtpUseCase(this._repository);

  Future<AuthSessionEntity> execute(String phone, String otp) =>
      _repository.verifyOtp(phone, otp);
}
