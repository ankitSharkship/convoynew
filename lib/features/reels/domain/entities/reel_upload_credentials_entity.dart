/// Direct-to-Bunny TUS upload credentials from `POST /api/videos`. The
/// backend never receives raw video bytes — the client uploads straight to
/// [tusUploadUrl] using these headers for Bunny's own auth.
class ReelUploadCredentialsEntity {
  final String videoId;
  final String tusUploadUrl;
  final Map<String, String> tusHeaders;

  const ReelUploadCredentialsEntity({
    required this.videoId,
    required this.tusUploadUrl,
    required this.tusHeaders,
  });
}
