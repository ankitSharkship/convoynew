import 'package:dio/dio.dart';

import '../../../../core/network/api_exception.dart';
import '../../domain/entities/reel_upload_credentials_entity.dart';

abstract class ReelUploadRemoteDataSource {
  Future<ReelUploadCredentialsEntity> createVideo({
    required String title,
    String? description,
    required List<String> categoryIds,
    List<String> hashtags,
    double? latitude,
    double? longitude,
  });

  /// Returns the video's status after re-checking it against Bunny
  /// (`pending_upload`/`processing`/`ready`/`rejected`/`failed`), or `null`
  /// if the request itself failed.
  Future<String?> syncStatus(String videoId);
}

class ReelUploadRemoteDataSourceImpl implements ReelUploadRemoteDataSource {
  final Dio _dio;

  ReelUploadRemoteDataSourceImpl(this._dio);

  @override
  Future<ReelUploadCredentialsEntity> createVideo({
    required String title,
    String? description,
    required List<String> categoryIds,
    List<String> hashtags = const [],
    double? latitude,
    double? longitude,
  }) async {
    try {
      final response = await _dio.post(
        '/api/videos',
        data: {
          'title': title,
          if (description != null && description.isNotEmpty)
            'description': description,
          'categoryIds': categoryIds,
          if (hashtags.isNotEmpty) 'hashtags': hashtags,
          if (latitude != null && longitude != null) ...{
            'latitude': latitude,
            'longitude': longitude,
          },
        },
      );
      final data = response.data as Map<String, dynamic>;
      final video = data['video'] as Map<String, dynamic>;
      final rawHeaders = data['tusHeaders'] as Map<String, dynamic>;
      return ReelUploadCredentialsEntity(
        videoId: video['id'] as String,
        tusUploadUrl: data['tusUploadUrl'] as String,
        tusHeaders: rawHeaders.map((k, v) => MapEntry(k, v.toString())),
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (_) {
      throw const ApiException();
    }
  }

  @override
  Future<String?> syncStatus(String videoId) async {
    try {
      final response = await _dio.post('/api/videos/$videoId/sync-status');
      final data = response.data as Map<String, dynamic>;
      final video = data['video'] as Map<String, dynamic>;
      return video['status'] as String?;
    } catch (_) {
      // Best-effort — see ReelUploadRepository.syncStatus.
      return null;
    }
  }
}
