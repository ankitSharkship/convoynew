import '../entities/reel_comment_entity.dart';
import '../entities/reel_engagement_entity.dart';
import '../repositories/reels_repository.dart';

class SetReelLikeUseCase {
  final ReelsRepository _repository;

  SetReelLikeUseCase(this._repository);

  Future<ReelLikeResultEntity> execute(String reelId, {required bool like}) =>
      like ? _repository.likeReel(reelId) : _repository.unlikeReel(reelId);
}

class RecordReelViewUseCase {
  final ReelsRepository _repository;

  RecordReelViewUseCase(this._repository);

  Future<void> execute(String reelId) => _repository.recordView(reelId);
}

class ShareReelUseCase {
  final ReelsRepository _repository;

  ShareReelUseCase(this._repository);

  Future<int> execute(String reelId, {String? channel}) =>
      _repository.shareReel(reelId, channel: channel);
}

class SetUserFollowUseCase {
  final ReelsRepository _repository;

  SetUserFollowUseCase(this._repository);

  Future<FollowResultEntity> execute(String userId, {required bool follow}) =>
      follow ? _repository.followUser(userId) : _repository.unfollowUser(userId);
}

class GetReelCommentsUseCase {
  final ReelsRepository _repository;

  GetReelCommentsUseCase(this._repository);

  Future<ReelCommentsPageEntity> execute(
    String reelId, {
    required int limit,
    required int offset,
  }) => _repository.getComments(reelId, limit: limit, offset: offset);
}

class AddReelCommentUseCase {
  final ReelsRepository _repository;

  AddReelCommentUseCase(this._repository);

  Future<ReelCommentAddedEntity> execute(String reelId, String body) =>
      _repository.addComment(reelId, body);
}

class DeleteReelCommentUseCase {
  final ReelsRepository _repository;

  DeleteReelCommentUseCase(this._repository);

  Future<int> execute(String reelId, String commentId) =>
      _repository.deleteComment(reelId, commentId);
}
