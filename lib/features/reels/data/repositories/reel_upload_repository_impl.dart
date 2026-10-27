import '../../domain/entities/reel_upload_credentials_entity.dart';
import '../../domain/repositories/reel_upload_repository.dart';
import '../datasources/reel_upload_remote_datasource.dart';

class ReelUploadRepositoryImpl implements ReelUploadRepository {
  final ReelUploadRemoteDataSource _remote;

  ReelUploadRepositoryImpl(this._remote);

  @override
  Future<ReelUploadCredentialsEntity> createVideo({
    required String title,
    String? description,
    required List<String> categoryIds,
    List<String> hashtags = const [],
    double? latitude,
    double? longitude,
  }) => _remote.createVideo(
    title: title,
    description: description,
    categoryIds: categoryIds,
    hashtags: hashtags,
    latitude: latitude,
    longitude: longitude,
  );

  @override
  Future<String?> syncStatus(String videoId) => _remote.syncStatus(videoId);
}
