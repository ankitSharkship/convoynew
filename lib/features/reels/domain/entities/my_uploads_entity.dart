import 'reel_entity.dart';

class MyUploadItemEntity {
  final ReelEntity reel;

  /// Private to the owner; `null` for reels that aren't ready yet (they
  /// aren't in `GET /users/{id}/reels`).
  final int? viewCount;

  const MyUploadItemEntity({required this.reel, this.viewCount});
}

class MyUploadsEntity {
  final int totalReels;
  final int totalLikes;
  final int totalViews;
  final List<MyUploadItemEntity> items;

  const MyUploadsEntity({
    required this.totalReels,
    required this.totalLikes,
    required this.totalViews,
    required this.items,
  });
}
