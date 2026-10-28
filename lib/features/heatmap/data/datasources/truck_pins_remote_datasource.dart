import 'package:dio/dio.dart';

import '../../../../core/network/api_exception.dart';
import '../../../search/data/models/truck_search_result_model.dart';
import '../../../search/domain/entities/truck_search_result_entity.dart';
import '../../domain/entities/geo_box.dart';
import '../../domain/entities/truck_pin_entity.dart';
import '../../domain/failures/truck_post_unavailable_exception.dart';
import '../models/truck_pins_model.dart';

/// The most pins asked for in one request (the server's own ceiling).
const truckPinsRequestLimit = 1000;

abstract class TruckPinsRemoteDataSource {
  Future<TruckPinsEntity> getPins(GeoBox box);
  Future<TruckSearchResultEntity> getPostDetail(String postId);
}

class TruckPinsRemoteDataSourceImpl implements TruckPinsRemoteDataSource {
  final Dio _dio;

  TruckPinsRemoteDataSourceImpl(this._dio);

  Future<T> _guard<T>(Future<T> Function() body) async {
    try {
      return await body();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException();
    }
  }

  @override
  Future<TruckPinsEntity> getPins(GeoBox box) => _guard(() async {
    final response = await _dio.get(
      '/api/heatmap/trucks/pins',
      queryParameters: {
        'minLat': box.minLat,
        'minLng': box.minLng,
        'maxLat': box.maxLat,
        'maxLng': box.maxLng,
        'limit': truckPinsRequestLimit,
      },
    );
    return TruckPinsModel.fromJson(response.data as Map<String, dynamic>);
  });

  @override
  Future<TruckSearchResultEntity> getPostDetail(String postId) async {
    try {
      final response = await _dio.get('/api/heatmap/trucks/posts/$postId');
      final data = response.data as Map<String, dynamic>;
      return truckSearchResultFromJson(data['post'] as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw const TruckPostUnavailableException();
      }
      throw ApiException.fromDioException(e);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException();
    }
  }
}
