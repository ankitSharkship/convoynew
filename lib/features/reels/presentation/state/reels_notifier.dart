import 'dart:math';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/dio_client.dart';
import '../../data/datasources/reels_remote_datasource.dart';
import '../../data/repositories/reels_repository_impl.dart';
import '../../domain/entities/reel_entity.dart';
import '../../domain/usecases/get_reels_usecase.dart';
import '../../domain/usecases/reel_engagement_usecases.dart';

part 'reels_notifier.g.dart';

const _reelsPageSize = 10;

@riverpod
ReelsRemoteDataSource reelsRemoteDataSource(ReelsRemoteDataSourceRef ref) {
  return ReelsRemoteDataSourceImpl(
    ref.watch(dioProvider),
    ref.watch(tokenStorageProvider),
  );
}

@riverpod
ReelsRepositoryImpl reelsRepository(ReelsRepositoryRef ref) {
  return ReelsRepositoryImpl(ref.watch(reelsRemoteDataSourceProvider));
}

@riverpod
GetReelsUseCase getReelsUseCase(GetReelsUseCaseRef ref) {
  return GetReelsUseCase(ref.watch(reelsRepositoryProvider));
}

@riverpod
GetReelCategoriesUseCase getReelCategoriesUseCase(
  GetReelCategoriesUseCaseRef ref,
) {
  return GetReelCategoriesUseCase(ref.watch(reelsRepositoryProvider));
}

@riverpod
SetReelLikeUseCase setReelLikeUseCase(SetReelLikeUseCaseRef ref) {
  return SetReelLikeUseCase(ref.watch(reelsRepositoryProvider));
}

@riverpod
RecordReelViewUseCase recordReelViewUseCase(RecordReelViewUseCaseRef ref) {
  return RecordReelViewUseCase(ref.watch(reelsRepositoryProvider));
}

@riverpod
ShareReelUseCase shareReelUseCase(ShareReelUseCaseRef ref) {
  return ShareReelUseCase(ref.watch(reelsRepositoryProvider));
}

@riverpod
SetUserFollowUseCase setUserFollowUseCase(SetUserFollowUseCaseRef ref) {
  return SetUserFollowUseCase(ref.watch(reelsRepositoryProvider));
}

/// Categories for the upload picker and the feed filter chips.
@riverpod
Future<List<ReelCategoryEntity>> reelCategories(ReelCategoriesRef ref) {
  return ref.watch(getReelCategoriesUseCaseProvider).execute();
}

/// The category id currently selected on the Reels tab (`null` = all).
@riverpod
class SelectedReelCategory extends _$SelectedReelCategory {
  @override
  String? build() => null;

  void select(String? categoryId) => state = categoryId;
}

class ReelsFeedState {
  final List<ReelEntity> items;
  final bool isLoading;
  final bool hasMore;
  final String? error;

  const ReelsFeedState({
    this.items = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.error,
  });

  ReelsFeedState copyWith({
    List<ReelEntity>? items,
    bool? isLoading,
    bool? hasMore,
    String? error,
  }) {
    return ReelsFeedState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      error: error,
    );
  }
}

/// Backs both the home screen's "Trending Road Reels" preview rail (the
/// unfiltered feed, `categoryId == null`, just taking the first few items)
/// and the full-screen Reels tab's infinite-scroll feed — one shared feed
/// per category, same as Home's post/search history sections reuse a single
/// provider for their preview + "view all".
@riverpod
class ReelsFeedNotifier extends _$ReelsFeedNotifier {
  final _likesInFlight = <String>{};
  final _followsInFlight = <String>{};

  @override
  ReelsFeedState build(String? categoryId) {
    Future.microtask(loadNextPage);
    return const ReelsFeedState();
  }

  Future<void> loadNextPage() async {
    if (state.isLoading || !state.hasMore) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final page = await ref
          .read(getReelsUseCaseProvider)
          .execute(
            limit: _reelsPageSize,
            offset: state.items.length,
            categoryId: categoryId,
          );
      state = state.copyWith(
        items: [...state.items, ...page.items],
        isLoading: false,
        hasMore: page.hasMore,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Refetches page one and swaps it in without first clearing [items], so
  /// a pull-to-refresh on the Reels screen doesn't flash to an empty state
  /// while a reel is actively playing.
  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final page = await ref
          .read(getReelsUseCaseProvider)
          .execute(limit: _reelsPageSize, offset: 0, categoryId: categoryId);
      state = ReelsFeedState(items: page.items, hasMore: page.hasMore);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void _patch(String reelId, ReelEntity Function(ReelEntity) update) {
    state = state.copyWith(
      items: [
        for (final r in state.items) r.id == reelId ? update(r) : r,
      ],
    );
  }

  ReelEntity? _find(String reelId) {
    for (final r in state.items) {
      if (r.id == reelId) return r;
    }
    return null;
  }

  /// Optimistic like/unlike, reconciled with the server's count (or rolled
  /// back if the request fails).
  Future<void> toggleLike(String reelId) async {
    final reel = _find(reelId);
    if (reel == null || !_likesInFlight.add(reelId)) return;
    final wasLiked = reel.likedByMe;
    _patch(
      reelId,
      (r) => r.copyWith(
        likedByMe: !wasLiked,
        likeCount: max(0, r.likeCount + (wasLiked ? -1 : 1)),
      ),
    );
    try {
      final result = await ref
          .read(setReelLikeUseCaseProvider)
          .execute(reelId, like: !wasLiked);
      _patch(
        reelId,
        (r) => r.copyWith(
          likedByMe: result.likedByMe,
          likeCount: result.likeCount,
        ),
      );
    } catch (_) {
      _patch(
        reelId,
        (r) =>
            r.copyWith(likedByMe: wasLiked, likeCount: reel.likeCount),
      );
    } finally {
      _likesInFlight.remove(reelId);
    }
  }

  /// Optimistic follow/unfollow; applies to every loaded reel by that author.
  Future<void> toggleFollow(String authorId) async {
    ReelAuthorEntity? author;
    for (final r in state.items) {
      if (r.author?.id == authorId) {
        author = r.author;
        break;
      }
    }
    if (author == null || !_followsInFlight.add(authorId)) return;
    final wasFollowing = author.followedByMe;
    final originalCount = author.followerCount;

    void apply(bool following, int count) {
      state = state.copyWith(
        items: [
          for (final r in state.items)
            r.author?.id == authorId
                ? r.copyWith(
                    author: r.author!.copyWith(
                      followedByMe: following,
                      followerCount: count,
                    ),
                  )
                : r,
        ],
      );
    }

    apply(!wasFollowing, max(0, originalCount + (wasFollowing ? -1 : 1)));
    try {
      final result = await ref
          .read(setUserFollowUseCaseProvider)
          .execute(authorId, follow: !wasFollowing);
      apply(result.followedByMe, result.followerCount);
    } catch (_) {
      apply(wasFollowing, originalCount);
    } finally {
      _followsInFlight.remove(authorId);
    }
  }

  void setCommentCount(String reelId, int count) =>
      _patch(reelId, (r) => r.copyWith(commentCount: count));

  /// Records a completed native share. Returns silently on failure — the
  /// count is analytics, not something the user needs to be told about.
  Future<void> recordShare(String reelId) async {
    try {
      final count = await ref.read(shareReelUseCaseProvider).execute(reelId);
      _patch(reelId, (r) => r.copyWith(shareCount: count));
    } catch (_) {}
  }

  /// Fire-and-forget view ping; the backend de-dupes and ignores the creator.
  Future<void> recordView(String reelId) async {
    try {
      await ref.read(recordReelViewUseCaseProvider).execute(reelId);
    } catch (_) {}
  }
}
