import '../entities/my_uploads_entity.dart';
import '../entities/reel_comment_entity.dart';
import '../entities/reel_engagement_entity.dart';
import '../entities/reel_entity.dart';
import '../entities/reels_feed_key.dart';

abstract class ReelsRepository {
  Future<ReelsPageEntity> getReels({
    required int limit,
    required int offset,
    String? categoryId,
    String? areaCell,
    ReelsSort sort = ReelsSort.latest,
  });
  Future<List<ReelCategoryEntity>> getCategories();
  Future<ReelLikeResultEntity> likeReel(String reelId);
  Future<ReelLikeResultEntity> unlikeReel(String reelId);
  Future<void> recordView(String reelId);
  Future<int> shareReel(String reelId, {String? channel});
  Future<ReelCommentsPageEntity> getComments(
    String reelId, {
    required int limit,
    required int offset,
  });
  Future<ReelCommentAddedEntity> addComment(String reelId, String body);
  Future<int> deleteComment(String reelId, String commentId);
  Future<FollowResultEntity> followUser(String userId);
  Future<FollowResultEntity> unfollowUser(String userId);
  Future<MyUploadsEntity> getMyUploads();
}
