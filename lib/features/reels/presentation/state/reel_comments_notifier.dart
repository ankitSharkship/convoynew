import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/reel_comment_entity.dart';
import '../../domain/usecases/reel_engagement_usecases.dart';
import 'reels_notifier.dart';

part 'reel_comments_notifier.g.dart';

const _commentsPageSize = 20;

@riverpod
GetReelCommentsUseCase getReelCommentsUseCase(GetReelCommentsUseCaseRef ref) {
  return GetReelCommentsUseCase(ref.watch(reelsRepositoryProvider));
}

@riverpod
AddReelCommentUseCase addReelCommentUseCase(AddReelCommentUseCaseRef ref) {
  return AddReelCommentUseCase(ref.watch(reelsRepositoryProvider));
}

@riverpod
DeleteReelCommentUseCase deleteReelCommentUseCase(
  DeleteReelCommentUseCaseRef ref,
) {
  return DeleteReelCommentUseCase(ref.watch(reelsRepositoryProvider));
}

class ReelCommentsState {
  final List<ReelCommentEntity> items;
  final int total;
  final bool isLoading;
  final bool hasMore;
  final String? error;

  const ReelCommentsState({
    this.items = const [],
    this.total = 0,
    this.isLoading = false,
    this.hasMore = true,
    this.error,
  });

  ReelCommentsState copyWith({
    List<ReelCommentEntity>? items,
    int? total,
    bool? isLoading,
    bool? hasMore,
    String? error,
  }) {
    return ReelCommentsState(
      items: items ?? this.items,
      total: total ?? this.total,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      error: error,
    );
  }
}

/// Comments for one reel (newest first), backing the comments bottom sheet.
/// [addComment] / [deleteComment] return the reel's new comment count (or
/// throw the API's message) so the caller can sync the feed's count.
@riverpod
class ReelCommentsNotifier extends _$ReelCommentsNotifier {
  @override
  ReelCommentsState build(String reelId) {
    Future.microtask(loadNextPage);
    return const ReelCommentsState();
  }

  Future<void> loadNextPage() async {
    if (state.isLoading || !state.hasMore) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final page = await ref
          .read(getReelCommentsUseCaseProvider)
          .execute(reelId, limit: _commentsPageSize, offset: state.items.length);
      state = state.copyWith(
        items: [...state.items, ...page.items],
        total: page.total,
        isLoading: false,
        hasMore: page.hasMore,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> retry() async {
    state = state.copyWith(error: null);
    await loadNextPage();
  }

  Future<int> addComment(String body) async {
    final added = await ref
        .read(addReelCommentUseCaseProvider)
        .execute(reelId, body);
    state = state.copyWith(
      items: [added.comment, ...state.items],
      total: added.commentCount,
    );
    return added.commentCount;
  }

  Future<int> deleteComment(String commentId) async {
    final count = await ref
        .read(deleteReelCommentUseCaseProvider)
        .execute(reelId, commentId);
    state = state.copyWith(
      items: state.items.where((c) => c.id != commentId).toList(),
      total: count,
    );
    return count;
  }
}
