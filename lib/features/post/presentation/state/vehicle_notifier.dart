import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/datasources/vehicle_remote_datasource.dart';
import '../../data/repositories/vehicle_repository_impl.dart';
import '../../domain/entities/vehicle_entity.dart';
import '../../domain/entities/vehicle_verification_entity.dart';
import '../../domain/usecases/add_vehicle_usecase.dart';
import '../../domain/usecases/delete_vehicle_usecase.dart';
import '../../domain/usecases/get_vehicles_usecase.dart';
import '../../domain/usecases/verify_vehicle_usecase.dart';

part 'vehicle_notifier.g.dart';

@riverpod
VehicleRemoteDataSource vehicleRemoteDataSource(
  VehicleRemoteDataSourceRef ref,
) {
  return VehicleRemoteDataSourceImpl(ref.watch(dioProvider));
}

@riverpod
VehicleRepositoryImpl vehicleRepository(VehicleRepositoryRef ref) {
  return VehicleRepositoryImpl(ref.watch(vehicleRemoteDataSourceProvider));
}

@riverpod
GetVehiclesUseCase getVehiclesUseCase(GetVehiclesUseCaseRef ref) {
  return GetVehiclesUseCase(ref.watch(vehicleRepositoryProvider));
}

@riverpod
DeleteVehicleUseCase deleteVehicleUseCase(DeleteVehicleUseCaseRef ref) {
  return DeleteVehicleUseCase(ref.watch(vehicleRepositoryProvider));
}

@riverpod
VerifyVehicleUseCase verifyVehicleUseCase(VerifyVehicleUseCaseRef ref) {
  return VerifyVehicleUseCase(ref.watch(vehicleRepositoryProvider));
}

@riverpod
AddVehicleUseCase addVehicleUseCase(AddVehicleUseCaseRef ref) {
  return AddVehicleUseCase(ref.watch(vehicleRepositoryProvider));
}

@riverpod
class VehicleNotifier extends _$VehicleNotifier {
  @override
  Future<List<VehicleEntity>> build() async {
    final userId = await ref.read(tokenStorageProvider).getUserId();
    if (userId == null) throw const ApiException();
    return ref.read(getVehiclesUseCaseProvider).execute(userId);
  }

  Future<void> deleteVehicle(String vehicleId) async {
    final userId = await ref.read(tokenStorageProvider).getUserId();
    if (userId == null) throw const ApiException();

    await ref
        .read(deleteVehicleUseCaseProvider)
        .execute(userId: userId, vehicleId: vehicleId);

    final current = await future;
    state = AsyncData(current.where((v) => v.id != vehicleId).toList());
  }

  /// Looks up vehicles by (partial) truck number for the search-as-you-type
  /// picker. Returns a fresh list from the API rather than filtering the
  /// cached [build] result, so it always reflects the server's own match —
  /// it deliberately does not touch this notifier's list state.
  Future<List<VehicleEntity>> searchVehicles(String? truckNumber) async {
    final userId = await ref.read(tokenStorageProvider).getUserId();
    if (userId == null) throw const ApiException();
    return ref
        .read(getVehiclesUseCaseProvider)
        .execute(userId, truckNumber: truckNumber);
  }

  /// A pre-check only — does not touch the vehicle list state.
  Future<VehicleVerificationEntity> verifyVehicle(String vehicleNumber) async {
    final userId = await ref.read(tokenStorageProvider).getUserId();
    if (userId == null) throw const ApiException();
    return ref
        .read(verifyVehicleUseCaseProvider)
        .execute(userId: userId, vehicleNumber: vehicleNumber);
  }

  Future<VehicleEntity> addVehicle({
    required String vehicleNumber,
    required String truckType,
    required int capacity,
  }) async {
    final userId = await ref.read(tokenStorageProvider).getUserId();
    if (userId == null) throw const ApiException();

    final vehicle = await ref
        .read(addVehicleUseCaseProvider)
        .execute(
          userId: userId,
          vehicleNumber: vehicleNumber,
          truckType: truckType,
          capacity: capacity,
        );

    final current = await future;
    state = AsyncData([...current, vehicle]);
    return vehicle;
  }
}
