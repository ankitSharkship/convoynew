import 'package:dio/dio.dart';
import '../../../../core/network/api_exception.dart';
import '../../../search/domain/entities/location_entity.dart';
import '../../domain/entities/trip_entity.dart';
import '../models/trip_model.dart';

abstract class TripRemoteDataSource {
  Future<List<TripEntity>> getMyTrips(String userId);

  Future<TripEntity> reactivateTrip(String tripId);

  Future<void> deleteTrip(String tripId);

  Future<TripEntity> editTrip({
    required String tripId,
    required String vehicleId,
    required List<LocationEntity> destinations,
    required LocationEntity currentLocation,
    String? contactName,
    String? contactNumber,
  });
}

class TripRemoteDataSourceImpl implements TripRemoteDataSource {
  final Dio _dio;

  TripRemoteDataSourceImpl(this._dio);

  @override
  Future<List<TripEntity>> getMyTrips(String userId) async {
    try {
      final response = await _dio.get('/api/posts/my-posts/$userId');
      final data = response.data as Map<String, dynamic>;
      final posts = data['posts'] as List<dynamic>? ?? [];
      return posts
          .map((p) => TripModel.fromJson(p as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (_) {
      throw const ApiException();
    }
  }

  @override
  Future<TripEntity> reactivateTrip(String tripId) async {
    try {
      final response = await _dio.post('/api/posts/reactivate/$tripId');
      final data = response.data as Map<String, dynamic>;
      return TripModel.fromJson(data['post'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (_) {
      throw const ApiException();
    }
  }

  @override
  Future<void> deleteTrip(String tripId) async {
    try {
      await _dio.delete('/api/posts/delete/$tripId');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (_) {
      throw const ApiException();
    }
  }

  @override
  Future<TripEntity> editTrip({
    required String tripId,
    required String vehicleId,
    required List<LocationEntity> destinations,
    required LocationEntity currentLocation,
    String? contactName,
    String? contactNumber,
  }) async {
    try {
      final response = await _dio.put(
        '/api/posts/edit/$tripId',
        data: {
          'vehicleId': vehicleId,
          'destinations': destinations.map((d) => d.toRequestJson()).toList(),
          'currentLocation': currentLocation.toRequestJson(),
          'contactName': ?contactName,
          'contactNumber': ?contactNumber,
        },
      );
      final data = response.data as Map<String, dynamic>;
      return TripModel.fromJson(data['post'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (_) {
      throw const ApiException();
    }
  }
}
