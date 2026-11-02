import 'package:dio/dio.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/network/token_storage.dart';
import '../../domain/entities/my_uploads_entity.dart';
import '../../domain/entities/reel_comment_entity.dart';
import '../../domain/entities/reel_engagement_entity.dart';
import '../../domain/entities/reel_entity.dart';
import '../../domain/entities/reels_feed_key.dart';
import '../models/reel_model.dart';

abstract class ReelsRemoteDataSource {
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
  Future<void> deleteReel(String reelId);
}

class ReelsRemoteDataSourceImpl implements ReelsRemoteDataSource {
  final Dio _dio;
  final TokenStorage _tokenStorage;

  ReelsRemoteDataSourceImpl(this._dio, this._tokenStorage);

  Future<T> _guard<T>(Future<T> Function() body) async {
    try {
      return await body();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException();
    }
  }

  @override
  Future<ReelsPageEntity> getReels({
    required int limit,
    required int offset,
    String? categoryId,
    String? areaCell,
    ReelsSort sort = ReelsSort.latest,
  }) => _guard(() async {
    final response = await _dio.get(
      '/api/reels',
      queryParameters: {
        'limit': limit,
        'offset': offset,
        if (categoryId != null) 'category': categoryId,
        'h3Cell': ?areaCell,
        // Omitted for the default so the plain feed's request is unchanged.
        if (sort != ReelsSort.latest) 'sort': sort.apiValue,
      },
    );
    final data = response.data as Map<String, dynamic>;
    final items = (data['reels'] as List<dynamic>? ?? [])
        .map((e) => ReelModel.fromJson(e as Map<String, dynamic>))
        .toList();
    final total = data['total'] as int? ?? items.length;
    final respOffset = data['offset'] as int? ?? offset;
    final area = data['area'];
    return ReelsPageEntity(
      items: items,
      hasMore: respOffset + items.length < total,
      area: area is Map<String, dynamic> && area['h3Cell'] is String
          ? ReelsAreaEntity(
              h3Cell: area['h3Cell'] as String,
              label: area['label'] as String?,
              total: (area['total'] as num?)?.toInt() ?? items.length,
            )
          : null,
    );
  });

  @override
  Future<List<ReelCategoryEntity>> getCategories() => _guard(() async {
    final response = await _dio.get('/api/reel-categories');
    final data = response.data as Map<String, dynamic>;
    return (data['categories'] as List<dynamic>? ?? [])
        .map((e) => ReelCategoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  });

  @override
  Future<ReelLikeResultEntity> likeReel(String reelId) => _guard(() async {
    final response = await _dio.post('/api/reels/$reelId/like');
    return likeResultFromJson(response.data as Map<String, dynamic>);
  });

  @override
  Future<ReelLikeResultEntity> unlikeReel(String reelId) => _guard(() async {
    final response = await _dio.delete('/api/reels/$reelId/like');
    return likeResultFromJson(response.data as Map<String, dynamic>);
  });

  @override
  Future<void> recordView(String reelId) => _guard(() async {
    await _dio.post('/api/reels/$reelId/view');
  });

  @override
  Future<int> shareReel(String reelId, {String? channel}) => _guard(() async {
    final response = await _dio.post(
      '/api/reels/$reelId/share',
      data: channel == null ? null : {'channel': channel},
    );
    return (response.data as Map<String, dynamic>)['shareCount'] as int? ?? 0;
  });

  @override
  Future<ReelCommentsPageEntity> getComments(
    String reelId, {
    required int limit,
    required int offset,
  }) => _guard(() async {
    final response = await _dio.get(
      '/api/reels/$reelId/comments',
      queryParameters: {'limit': limit, 'offset': offset},
    );
    final data = response.data as Map<String, dynamic>;
    final items = (data['comments'] as List<dynamic>? ?? [])
        .map((e) => ReelCommentModel.fromJson(e as Map<String, dynamic>))
        .toList();
    final total = data['total'] as int? ?? items.length;
    final respOffset = data['offset'] as int? ?? offset;
    return ReelCommentsPageEntity(
      items: items,
      total: total,
      hasMore: respOffset + items.length < total,
    );
  });

  @override
  Future<ReelCommentAddedEntity> addComment(String reelId, String body) =>
      _guard(() async {
        final response = await _dio.post(
          '/api/reels/$reelId/comments',
          data: {'body': body},
        );
        final data = response.data as Map<String, dynamic>;
        return ReelCommentAddedEntity(
          comment: ReelCommentModel.fromJson(
            data['comment'] as Map<String, dynamic>,
          ),
          commentCount: data['commentCount'] as int? ?? 0,
        );
      });

  @override
  Future<int> deleteComment(String reelId, String commentId) =>
      _guard(() async {
        final response = await _dio.delete(
          '/api/reels/$reelId/comments/$commentId',
        );
        return (response.data as Map<String, dynamic>)['commentCount']
                as int? ??
            0;
      });

  @override
  Future<FollowResultEntity> followUser(String userId) => _guard(() async {
    final response = await _dio.post('/api/users/$userId/follow');
    return followResultFromJson(response.data as Map<String, dynamic>);
  });

  @override
  Future<FollowResultEntity> unfollowUser(String userId) => _guard(() async {
    final response = await _dio.delete('/api/users/$userId/follow');
    return followResultFromJson(response.data as Map<String, dynamic>);
  });

  @override
  Future<void> deleteReel(String reelId) => _guard(() async {
    await _dio.delete('/api/reels/$reelId');
  });

  @override
  Future<MyUploadsEntity> getMyUploads() => _guard(() async {
    final userId = await _tokenStorage.getUserId();
    if (userId == null) throw const ApiException();
    // Both endpoints cap `limit` at 100.
    final responses = await Future.wait([
      _dio.get(
        '/api/users/$userId/videos',
        queryParameters: {'limit': 100, 'offset': 0},
      ),
      _dio.get(
        '/api/users/$userId/reels',
        queryParameters: {'limit': 100, 'offset': 0},
      ),
    ]);
    return myUploadsFromJson(
      videos: responses[0].data as Map<String, dynamic>,
      creatorReels: responses[1].data as Map<String, dynamic>,
    );
  });
}
