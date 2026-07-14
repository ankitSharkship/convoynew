import 'package:dio/dio.dart';
import '../../../../core/network/api_exception.dart';
import '../../../search/domain/entities/location_entity.dart';
import '../../domain/entities/post_entity.dart';
import '../models/post_model.dart';

abstract class PostRemoteDataSource {
  Future<PostEntity> submitPost({
    required String userId,
    required String vehicleId,
    required LocationEntity origin,
    required List<LocationEntity> destinations,
    required LocationEntity currentLocation,
    required DateTime availableDate,
    String? contactName,
    String? contactNumber,
  });
}

class PostRemoteDataSourceImpl implements PostRemoteDataSource {
  final Dio _dio;

  PostRemoteDataSourceImpl(this._dio);

  @override
  Future<PostEntity> submitPost({
    required String userId,
    required String vehicleId,
    required LocationEntity origin,
    required List<LocationEntity> destinations,
    required LocationEntity currentLocation,
    required DateTime availableDate,
    String? contactName,
    String? contactNumber,
  }) async {
    try {
      final response = await _dio.post(
        '/api/posts/create/$userId',
        data: {
          'vehicleId': vehicleId,
          'origin': origin.toRequestJson(),
          'destinations': destinations.map((d) => d.toRequestJson()).toList(),
          'currentLocation': currentLocation.toRequestJson(),
          'available_date': _formatDate(availableDate),
          'contactName': ?contactName,
          'contactNumber': ?contactNumber,
        },
      );
      final data = response.data as Map<String, dynamic>;
      return PostModel.fromJson(data['post'] as Map<String, dynamic>);
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
