import '../repositories/device_repository.dart';

class SyncDeviceTokenIfChangedUseCase {
  final DeviceRepository _repository;

  SyncDeviceTokenIfChangedUseCase(this._repository);

  Future<void> execute(String userId) =>
      _repository.syncIfTokenChanged(userId);
}
