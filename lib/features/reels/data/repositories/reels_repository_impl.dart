import '../../domain/entities/my_uploads_entity.dart';
import '../../domain/entities/reel_comment_entity.dart';
import '../../domain/entities/reel_engagement_entity.dart';
import '../../domain/entities/reel_entity.dart';
import '../../domain/repositories/reels_repository.dart';
import '../datasources/reels_remote_datasource.dart';

class ReelsRepositoryImpl implements ReelsRepository {
  final ReelsRemoteDataSource _remote;

  ReelsRepositoryImpl(this._remote);

  @override
  Future<ReelsPageEntity> getReels({
    required int limit,
    required int offset,
    String? categoryId,
  }) => _remote.getReels(limit: limit, offset: offset, categoryId: categoryId);

  @override
  Future<List<ReelCategoryEntity>> getCategories() => _remote.getCategories();

  @override
  Future<ReelLikeResultEntity> likeReel(String reelId) =>
      _remote.likeReel(reelId);

  @override
  Future<ReelLikeResultEntity> unlikeReel(String reelId) =>
      _remote.unlikeReel(reelId);

  @override
  Future<void> recordView(String reelId) => _remote.recordView(reelId);

  @override
  Future<int> shareReel(String reelId, {String? channel}) =>
      _remote.shareReel(reelId, channel: channel);

  @override
  Future<ReelCommentsPageEntity> getComments(
    String reelId, {
    required int limit,
    required int offset,
  }) => _remote.getComments(reelId, limit: limit, offset: offset);

  @override
  Future<ReelCommentAddedEntity> addComment(String reelId, String body) =>
      _remote.addComment(reelId, body);

  @override
  Future<int> deleteComment(String reelId, String commentId) =>
      _remote.deleteComment(reelId, commentId);

  @override
  Future<FollowResultEntity> followUser(String userId) =>
      _remote.followUser(userId);

  @override
  Future<FollowResultEntity> unfollowUser(String userId) =>
      _remote.unfollowUser(userId);

  @override
  Future<MyUploadsEntity> getMyUploads() => _remote.getMyUploads();
}
