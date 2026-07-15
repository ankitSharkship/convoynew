import '../../domain/entities/vehicle_entity.dart';
import '../../domain/entities/vehicle_verification_entity.dart';
import '../../domain/repositories/vehicle_repository.dart';
import '../datasources/vehicle_remote_datasource.dart';

class VehicleRepositoryImpl implements VehicleRepository {
  final VehicleRemoteDataSource _remote;

  VehicleRepositoryImpl(this._remote);

  @override
  Future<List<VehicleEntity>> getVehicles(String userId) =>
      _remote.getVehicles(userId);

  @override
  Future<void> deleteVehicle({
    required String userId,
    required String vehicleId,
  }) => _remote.deleteVehicle(userId: userId, vehicleId: vehicleId);

  @override
  Future<VehicleVerificationEntity> verifyVehicle({
    required String userId,
    required String vehicleNumber,
  }) => _remote.verifyVehicle(userId: userId, vehicleNumber: vehicleNumber);

  @override
  Future<VehicleEntity> addVehicle({
    required String userId,
    required String vehicleNumber,
    required String truckType,
    required int capacity,
  }) => _remote.addVehicle(
    userId: userId,
    vehicleNumber: vehicleNumber,
    truckType: truckType,
    capacity: capacity,
  );
}
