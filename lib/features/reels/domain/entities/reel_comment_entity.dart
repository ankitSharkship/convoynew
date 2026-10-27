class ReelCommentAuthorEntity {
  final String id;
  final String? name;
  final String? profilePhoto;

  const ReelCommentAuthorEntity({
    required this.id,
    this.name,
    this.profilePhoto,
  });
}

class ReelCommentEntity {
  final String id;
  final String reelId;
  final String body;
  final ReelCommentAuthorEntity? author;
  final bool canDelete;
  final DateTime createdAt;

  const ReelCommentEntity({
    required this.id,
    required this.reelId,
    required this.body,
    this.author,
    required this.canDelete,
    required this.createdAt,
  });
}

class ReelCommentsPageEntity {
  final List<ReelCommentEntity> items;
  final int total;
  final bool hasMore;

  const ReelCommentsPageEntity({
    required this.items,
    required this.total,
    required this.hasMore,
  });
}

/// Result of posting a comment: the created comment plus the reel's new
/// total, so the feed's comment count can be updated without a refetch.
class ReelCommentAddedEntity {
  final ReelCommentEntity comment;
  final int commentCount;

  const ReelCommentAddedEntity({
    required this.comment,
    required this.commentCount,
  });
}
