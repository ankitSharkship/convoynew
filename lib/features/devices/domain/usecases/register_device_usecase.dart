import '../repositories/device_repository.dart';

class RegisterDeviceUseCase {
  final DeviceRepository _repository;

  RegisterDeviceUseCase(this._repository);

  Future<void> execute(String userId) => _repository.registerDevice(userId);
}
