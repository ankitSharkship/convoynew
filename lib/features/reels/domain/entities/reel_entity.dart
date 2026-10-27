class ReelAuthorEntity {
  final String id;
  final String? name;
  final String? profilePhoto;
  final bool followedByMe;
  final int followerCount;
  final bool isMe;

  const ReelAuthorEntity({
    required this.id,
    this.name,
    this.profilePhoto,
    this.followedByMe = false,
    this.followerCount = 0,
    this.isMe = false,
  });

  ReelAuthorEntity copyWith({bool? followedByMe, int? followerCount}) {
    return ReelAuthorEntity(
      id: id,
      name: name,
      profilePhoto: profilePhoto,
      followedByMe: followedByMe ?? this.followedByMe,
      followerCount: followerCount ?? this.followerCount,
      isMe: isMe,
    );
  }
}

class ReelLocationEntity {
  final String? city;
  final String? state;

  const ReelLocationEntity({this.city, this.state});

  /// "Nagpur, Maharashtra", or whichever half is known; null if neither is.
  String? get label {
    final parts = [city, state].whereType<String>().where((s) => s.isNotEmpty);
    return parts.isEmpty ? null : parts.join(', ');
  }
}

class ReelCategoryEntity {
  final String id;
  final String slug;
  final String name;

  const ReelCategoryEntity({
    required this.id,
    required this.slug,
    required this.name,
  });
}

class ReelEntity {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final String status;
  final int? durationSeconds;
  /// Bunny's raw .m3u8 — informational only. Use [streamUrl] for playback.
  final String? playbackUrl;
  final String? thumbnailUrl;
  /// Relative path to resolve against the API base URL and play, e.g.
  /// `/api/videos/{id}/fast-start.m3u8`. Only set once [status] is "ready".
  final String? streamUrl;
  final String? rejectionReason;
  final List<String> hashtags;
  final ReelLocationEntity? location;
  final List<ReelCategoryEntity> categories;
  final int likeCount;
  final int commentCount;
  final int shareCount;
  final bool likedByMe;
  final ReelAuthorEntity? author;
  final DateTime createdAt;

  const ReelEntity({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.status,
    this.durationSeconds,
    this.playbackUrl,
    this.thumbnailUrl,
    this.streamUrl,
    this.rejectionReason,
    this.hashtags = const [],
    this.location,
    this.categories = const [],
    this.likeCount = 0,
    this.commentCount = 0,
    this.shareCount = 0,
    this.likedByMe = false,
    this.author,
    required this.createdAt,
  });

  ReelEntity copyWith({
    int? likeCount,
    int? commentCount,
    int? shareCount,
    bool? likedByMe,
    ReelAuthorEntity? author,
  }) {
    return ReelEntity(
      id: id,
      userId: userId,
      title: title,
      description: description,
      status: status,
      durationSeconds: durationSeconds,
      playbackUrl: playbackUrl,
      thumbnailUrl: thumbnailUrl,
      streamUrl: streamUrl,
      rejectionReason: rejectionReason,
      hashtags: hashtags,
      location: location,
      categories: categories,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      shareCount: shareCount ?? this.shareCount,
      likedByMe: likedByMe ?? this.likedByMe,
      author: author ?? this.author,
      createdAt: createdAt,
    );
  }
}

/// A page of reels from `GET /api/reels`, with just enough info to drive
/// infinite scroll (`hasMore`) without the UI layer needing to know about
/// limit/offset/total itself.
class ReelsPageEntity {
  final List<ReelEntity> items;
  final bool hasMore;

  const ReelsPageEntity({required this.items, required this.hasMore});
}
