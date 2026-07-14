import '../repositories/auth_repository.dart';

class SendOtpUseCase {
  final AuthRepository _repository;

  SendOtpUseCase(this._repository);

  Future<void> execute(String phone) => _repository.sendOtp(phone);
}
