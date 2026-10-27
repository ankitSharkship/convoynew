import '../entities/reel_upload_credentials_entity.dart';
import '../repositories/reel_upload_repository.dart';

class CreateReelUploadUseCase {
  final ReelUploadRepository _repository;

  CreateReelUploadUseCase(this._repository);

  Future<ReelUploadCredentialsEntity> execute({
    required String title,
    String? description,
    required List<String> categoryIds,
    List<String> hashtags = const [],
    double? latitude,
    double? longitude,
  }) => _repository.createVideo(
    title: title,
    description: description,
    categoryIds: categoryIds,
    hashtags: hashtags,
    latitude: latitude,
    longitude: longitude,
  );
}
