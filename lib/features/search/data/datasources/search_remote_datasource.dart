import 'package:dio/dio.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/entities/location_entity.dart';
import '../../domain/entities/truck_search_result_entity.dart';
import '../models/location_model.dart';
import '../models/truck_search_result_model.dart';

abstract class SearchRemoteDataSource {
  Future<List<LocationEntity>> searchLocations(String query);

  Future<TruckSearchResultPage> searchTrucks({
    required LocationEntity? origin,
    required LocationEntity? destination,
    required String? truckType,
    required int radiusKm,
    required DateTime availableDate,
    required int page,
    required int? capacity,
  });
}

class SearchRemoteDataSourceImpl implements SearchRemoteDataSource {
  final Dio _dio;

  SearchRemoteDataSourceImpl(this._dio);

  @override
  Future<List<LocationEntity>> searchLocations(String query) async {
    try {
      final response = await _dio.get(
        '/api/locations/search',
        queryParameters: {'query': query},
      );
      final data = response.data as Map<String, dynamic>;
      final locations = data['locations'] as List<dynamic>? ?? [];
      return locations
          .map((e) => LocationModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (_) {
      throw const ApiException();
    }
  }

  @override
  Future<TruckSearchResultPage> searchTrucks({
    required LocationEntity? origin,
    required LocationEntity? destination,
    required String? truckType,
    required int radiusKm,
    required DateTime availableDate,
    required int page,
    required int? capacity,
  }) async {
    try {
      final response = await _dio.post(
        '/api/search/trucks',
        data: {
          if (origin != null) 'origin': origin.toRequestJson(),
          if (destination != null) 'destination': destination.toRequestJson(),
          'truckType': truckType,
          'radius_km': radiusKm,
          'available_date': _formatDate(availableDate),
          'page': page,
          'capacity': capacity,
        },
      );
      return truckSearchResultPageFromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (_) {
      throw const ApiException();
    }
  }
}

String _formatDate(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';
