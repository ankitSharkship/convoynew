import '../entities/my_uploads_entity.dart';
import '../entities/reel_entity.dart';
import '../entities/reels_feed_key.dart';
import '../repositories/reels_repository.dart';

class GetReelsUseCase {
  final ReelsRepository _repository;

  GetReelsUseCase(this._repository);

  Future<ReelsPageEntity> execute({
    required int limit,
    required int offset,
    String? categoryId,
    String? areaCell,
    ReelsSort sort = ReelsSort.latest,
  }) => _repository.getReels(
    limit: limit,
    offset: offset,
    categoryId: categoryId,
    areaCell: areaCell,
    sort: sort,
  );
}

class GetReelCategoriesUseCase {
  final ReelsRepository _repository;

  GetReelCategoriesUseCase(this._repository);

  Future<List<ReelCategoryEntity>> execute() => _repository.getCategories();
}

class GetMyUploadsUseCase {
  final ReelsRepository _repository;

  GetMyUploadsUseCase(this._repository);

  Future<MyUploadsEntity> execute() => _repository.getMyUploads();
}

class DeleteReelUseCase {
  final ReelsRepository _repository;

  DeleteReelUseCase(this._repository);

  Future<void> execute(String reelId) => _repository.deleteReel(reelId);
}
