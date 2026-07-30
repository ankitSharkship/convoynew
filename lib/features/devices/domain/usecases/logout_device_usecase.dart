import '../repositories/device_repository.dart';

class LogoutDeviceUseCase {
  final DeviceRepository _repository;

  LogoutDeviceUseCase(this._repository);

  Future<void> execute(String userId) => _repository.logoutDevice(userId);
}
