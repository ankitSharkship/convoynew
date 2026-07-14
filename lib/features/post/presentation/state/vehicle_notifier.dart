import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/router/app_router.dart';
import '../../data/datasources/vehicle_local_datasource.dart';
import '../../data/models/vehicle_model.dart';

part 'vehicle_notifier.g.dart';

@riverpod
VehicleLocalDataSource vehicleLocalDataSource(VehicleLocalDataSourceRef ref) {
  return VehicleLocalDataSourceImpl(ref.watch(sharedPreferencesProvider));
}

@riverpod
class VehicleNotifier extends _$VehicleNotifier {
  @override
  Future<List<VehicleModel>> build() async {
    return ref.read(vehicleLocalDataSourceProvider).getVehicles();
  }

  Future<void> addVehicle({
    required String number,
    required String type,
    required String capacity,
  }) async {
    final current = await future;
    final updated = [
      ...current,
      VehicleModel(number: number, type: type, capacity: capacity),
    ];
    await ref.read(vehicleLocalDataSourceProvider).saveVehicles(updated);
    state = AsyncData(updated);
  }
}
