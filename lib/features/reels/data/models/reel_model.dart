import '../../domain/entities/my_uploads_entity.dart';
import '../../domain/entities/reel_comment_entity.dart';
import '../../domain/entities/reel_engagement_entity.dart';
import '../../domain/entities/reel_entity.dart';

/// Backend timestamps are UTC but carry no timezone suffix — parse them as UTC.
DateTime _parseUtc(String raw) {
  final hasZone = raw.endsWith('Z') || RegExp(r'[+-]\d{2}:\d{2}$').hasMatch(raw);
  return DateTime.parse(hasZone ? raw : '${raw}Z');
}

ReelAuthorEntity? _authorFromJson(Map<String, dynamic>? json) {
  if (json == null) return null;
  return ReelAuthorEntity(
    id: json['id'] as String,
    name: json['name'] as String?,
    profilePhoto: json['profilePhoto'] as String?,
    followedByMe: json['followedByMe'] as bool? ?? false,
    followerCount: json['followerCount'] as int? ?? 0,
    isMe: json['isMe'] as bool? ?? false,
  );
}

class ReelModel extends ReelEntity {
  const ReelModel({
    required super.id,
    required super.userId,
    required super.title,
    super.description,
    required super.status,
    super.durationSeconds,
    super.playbackUrl,
    super.thumbnailUrl,
    super.streamUrl,
    super.rejectionReason,
    super.hashtags,
    super.location,
    super.categories,
    super.likeCount,
    super.commentCount,
    super.shareCount,
    super.likedByMe,
    super.author,
    required super.createdAt,
  });

  factory ReelModel.fromJson(Map<String, dynamic> json) {
    final location = json['location'] as Map<String, dynamic>?;
    return ReelModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      status: json['status'] as String? ?? 'unknown',
      durationSeconds: json['durationSeconds'] as int?,
      playbackUrl: json['playbackUrl'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      streamUrl: json['streamUrl'] as String?,
      rejectionReason: json['rejectionReason'] as String?,
      hashtags: (json['hashtags'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      location: location == null
          ? null
          : ReelLocationEntity(
              city: location['city'] as String?,
              state: location['state'] as String?,
            ),
      categories: (json['categories'] as List<dynamic>? ?? [])
          .map((e) => ReelCategoryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      likeCount: json['likeCount'] as int? ?? 0,
      commentCount: json['commentCount'] as int? ?? 0,
      shareCount: json['shareCount'] as int? ?? 0,
      likedByMe: json['likedByMe'] as bool? ?? false,
      author: _authorFromJson(json['author'] as Map<String, dynamic>?),
      createdAt: _parseUtc(
        (json['postedAt'] ?? json['createdAt']) as String,
      ),
    );
  }
}

class ReelCategoryModel extends ReelCategoryEntity {
  const ReelCategoryModel({
    required super.id,
    required super.slug,
    required super.name,
  });

  factory ReelCategoryModel.fromJson(Map<String, dynamic> json) {
    return ReelCategoryModel(
      id: json['id'] as String,
      slug: json['slug'] as String? ?? '',
      name: json['name'] as String? ?? '',
    );
  }
}

class ReelCommentModel extends ReelCommentEntity {
  const ReelCommentModel({
    required super.id,
    required super.reelId,
    required super.body,
    super.author,
    required super.canDelete,
    required super.createdAt,
  });

  factory ReelCommentModel.fromJson(Map<String, dynamic> json) {
    final author = json['author'] as Map<String, dynamic>?;
    return ReelCommentModel(
      id: json['id'] as String,
      reelId: json['reelId'] as String,
      body: json['body'] as String? ?? '',
      author: author == null
          ? null
          : ReelCommentAuthorEntity(
              id: author['id'] as String,
              name: author['name'] as String?,
              profilePhoto: author['profilePhoto'] as String?,
            ),
      canDelete: json['canDelete'] as bool? ?? false,
      createdAt: _parseUtc(json['createdAt'] as String),
    );
  }
}

ReelLikeResultEntity likeResultFromJson(Map<String, dynamic> json) {
  return ReelLikeResultEntity(
    likedByMe: json['likedByMe'] as bool? ?? false,
    likeCount: json['likeCount'] as int? ?? 0,
  );
}

FollowResultEntity followResultFromJson(Map<String, dynamic> json) {
  return FollowResultEntity(
    followedByMe: json['followedByMe'] as bool? ?? false,
    followerCount: json['followerCount'] as int? ?? 0,
  );
}

/// Merges `GET /users/{id}/videos` (every status, with categories) and
/// `GET /users/{id}/reels` (ready only, with private view counts + summary).
MyUploadsEntity myUploadsFromJson({
  required Map<String, dynamic> videos,
  required Map<String, dynamic> creatorReels,
}) {
  final viewCounts = <String, int>{
    for (final r in creatorReels['reels'] as List<dynamic>? ?? [])
      (r as Map<String, dynamic>)['id'] as String: r['viewCount'] as int? ?? 0,
  };
  final summary = creatorReels['summary'] as Map<String, dynamic>? ?? {};
  final items = (videos['videos'] as List<dynamic>? ?? [])
      .map((e) => ReelModel.fromJson(e as Map<String, dynamic>))
      .map((reel) => MyUploadItemEntity(reel: reel, viewCount: viewCounts[reel.id]))
      .toList();
  return MyUploadsEntity(
    totalReels: summary['totalReels'] as int? ?? items.length,
    totalLikes: summary['totalLikes'] as int? ?? 0,
    totalViews: summary['totalViews'] as int? ?? 0,
    items: items,
  );
}
