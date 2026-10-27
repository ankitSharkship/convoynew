class ReelLikeResultEntity {
  final bool likedByMe;
  final int likeCount;

  const ReelLikeResultEntity({required this.likedByMe, required this.likeCount});
}

class FollowResultEntity {
  final bool followedByMe;
  final int followerCount;

  const FollowResultEntity({
    required this.followedByMe,
    required this.followerCount,
  });
}
