import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/widgets/sheet_form_field.dart';
import '../state/reel_comments_notifier.dart';
import 'reel_avatar.dart';

/// Bottom sheet listing a reel's comments (newest first) with an input to
/// add one. [onCountChanged] receives the reel's new comment total after a
/// comment is posted or deleted.
class ReelCommentsSheet extends ConsumerStatefulWidget {
  final String reelId;
  final ValueChanged<int> onCountChanged;

  const ReelCommentsSheet({
    super.key,
    required this.reelId,
    required this.onCountChanged,
  });

  static Future<void> show(
    BuildContext context, {
    required String reelId,
    required ValueChanged<int> onCountChanged,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          ReelCommentsSheet(reelId: reelId, onCountChanged: onCountChanged),
    );
  }

  @override
  ConsumerState<ReelCommentsSheet> createState() => _ReelCommentsSheetState();
}

class _ReelCommentsSheetState extends ConsumerState<ReelCommentsSheet> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isPosting = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.extentAfter < 200) {
        ref
            .read(reelCommentsNotifierProvider(widget.reelId).notifier)
            .loadNextPage();
      }
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _showError(Object e) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(ApiException.messageFor(e))));
  }

  Future<void> _post() async {
    final body = _inputController.text.trim();
    if (body.isEmpty || _isPosting) return;
    setState(() => _isPosting = true);
    try {
      final count = await ref
          .read(reelCommentsNotifierProvider(widget.reelId).notifier)
          .addComment(body);
      _inputController.clear();
      widget.onCountChanged(count);
      if (_scrollController.hasClients) _scrollController.jumpTo(0);
    } catch (e) {
      _showError(e);
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  Future<void> _delete(String commentId) async {
    try {
      final count = await ref
          .read(reelCommentsNotifierProvider(widget.reelId).notifier)
          .deleteComment(commentId);
      widget.onCountChanged(count);
    } catch (e) {
      _showError(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(reelCommentsNotifierProvider(widget.reelId));
    final keyboardInset = MediaQuery.of(context).viewInsets.bottom;

    Widget body;
    if (state.items.isEmpty && state.isLoading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (state.items.isEmpty && state.error != null) {
      body = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.somethingWentWrong),
            TextButton(
              onPressed: () => ref
                  .read(reelCommentsNotifierProvider(widget.reelId).notifier)
                  .retry(),
              child: Text(l10n.tryAgain),
            ),
          ],
        ),
      );
    } else if (state.items.isEmpty) {
      body = Center(
        child: Text(
          l10n.reelCommentsEmpty,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
      );
    } else {
      body = ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        itemCount: state.items.length + (state.isLoading ? 1 : 0),
        itemBuilder: (context, i) {
          if (i >= state.items.length) {
            return const Padding(
              padding: EdgeInsets.all(12),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          }
          final comment = state.items[i];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ReelAvatar(
                  photo: comment.author?.profilePhoto,
                  name: comment.author?.name,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comment.author?.name ?? '',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        comment.body,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (comment.canDelete)
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    tooltip: l10n.reelCommentDelete,
                    icon: const Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: AppColors.textTertiary,
                    ),
                    onPressed: () => _delete(comment.id),
                  ),
              ],
            ),
          );
        },
      );
    }

    return Padding(
      padding: EdgeInsets.only(bottom: keyboardInset),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.65,
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 8, 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${l10n.reelCommentsTitle} (${state.total})',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.divider),
            Expanded(child: body),
            const Divider(height: 1, color: AppColors.divider),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _inputController,
                        maxLength: 1000,
                        minLines: 1,
                        maxLines: 3,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: sheetFieldDecoration(
                          l10n.reelCommentHint,
                        ).copyWith(counterText: ''),
                      ),
                    ),
                    const SizedBox(width: 4),
                    _isPosting
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : IconButton(
                            tooltip: l10n.reelCommentPost,
                            icon: const Icon(
                              Icons.send_rounded,
                              color: AppColors.primaryBlue,
                            ),
                            onPressed: _post,
                          ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
