import '../entities/reel_upload_credentials_entity.dart';

abstract class ReelUploadRepository {
  Future<ReelUploadCredentialsEntity> createVideo({
    required String title,
    String? description,
    required List<String> categoryIds,
    List<String> hashtags,
    double? latitude,
    double? longitude,
  });

  /// Best-effort local-dev substitute for Bunny's encoding-finished webhook,
  /// which can't reach a developer's machine. Failures are non-fatal — the
  /// video just stays in "processing" until something else triggers a sync.
  /// Returns the resulting status, or `null` if the request itself failed.
  Future<String?> syncStatus(String videoId);
}
