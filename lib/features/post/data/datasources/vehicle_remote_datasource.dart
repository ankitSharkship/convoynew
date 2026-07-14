import 'package:dio/dio.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/entities/vehicle_entity.dart';
import '../models/vehicle_model.dart';

abstract class VehicleRemoteDataSource {
  Future<List<VehicleEntity>> getVehicles(String userId);

  Future<void> deleteVehicle({
    required String userId,
    required String vehicleId,
  });
}

class VehicleRemoteDataSourceImpl implements VehicleRemoteDataSource {
  final Dio _dio;

  VehicleRemoteDataSourceImpl(this._dio);

  @override
  Future<List<VehicleEntity>> getVehicles(String userId) async {
    try {
      final response = await _dio.get('/api/vehicle/list/$userId');
      final data = response.data as Map<String, dynamic>;
      final vehicles = data['vehicles'] as List<dynamic>? ?? [];
      return vehicles
          .map((e) => VehicleModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (_) {
      throw const ApiException();
    }
  }

  @override
  Future<void> deleteVehicle({
    required String userId,
    required String vehicleId,
  }) async {
    try {
      await _dio.delete('/api/vehicle/remove/$userId/$vehicleId');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (_) {
      throw const ApiException();
    }
  }
}
