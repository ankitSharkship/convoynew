import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/widgets/sheet_form_field.dart';
import '../state/reel_upload_notifier.dart';
import '../state/reels_notifier.dart';

const _maxCategories = 5;
const _maxHashtags = 10;

class ReelDetailsScreen extends ConsumerStatefulWidget {
  final String videoPath;

  const ReelDetailsScreen({super.key, required this.videoPath});

  @override
  ConsumerState<ReelDetailsScreen> createState() => _ReelDetailsScreenState();
}

class _ReelDetailsScreenState extends ConsumerState<ReelDetailsScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  VideoPlayerController? _previewController;
  final _hashtagsController = TextEditingController();
  final _selectedCategoryIds = <String>{};
  bool _titleTouched = false;
  bool _submitAttempted = false;

  @override
  void initState() {
    super.initState();
    final controller = VideoPlayerController.file(File(widget.videoPath));
    controller.initialize().then((_) {
      if (mounted) setState(() => _previewController = controller);
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _hashtagsController.dispose();
    _previewController?.dispose();
    super.dispose();
  }

  /// Splits the free-text field on whitespace/commas, drops the optional
  /// '#', keeps only letters/digits/underscore (what the API accepts), and
  /// de-dupes case-insensitively.
  List<String> _parseHashtags() {
    final seen = <String>{};
    final tags = <String>[];
    for (final raw in _hashtagsController.text.split(RegExp(r'[\s,]+'))) {
      final tag = raw.replaceAll(RegExp(r'[^A-Za-z0-9_]'), '');
      if (tag.isNotEmpty && seen.add(tag.toLowerCase())) tags.add(tag);
    }
    return tags;
  }

  void _submit() {
    setState(() {
      _titleTouched = true;
      _submitAttempted = true;
    });
    final title = _titleController.text.trim();
    final hashtags = _parseHashtags();
    if (title.isEmpty ||
        _selectedCategoryIds.isEmpty ||
        hashtags.length > _maxHashtags) {
      return;
    }
    ref
        .read(reelUploadNotifierProvider.notifier)
        .upload(
          filePath: widget.videoPath,
          title: title,
          description: _descriptionController.text.trim(),
          categoryIds: _selectedCategoryIds.toList(),
          hashtags: hashtags,
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final uploadState = ref.watch(reelUploadNotifierProvider);

    ref.listen(reelUploadNotifierProvider, (previous, next) {
      if (next.phase == ReelUploadPhase.completed) {
        context.pushReplacement('/reels/create/success');
      }
    });

    final isBusy =
        uploadState.phase == ReelUploadPhase.creating ||
        uploadState.phase == ReelUploadPhase.uploading;
    final categoriesAsync = ref.watch(reelCategoriesProvider);
    final hashtagCount = _parseHashtags().length;
    final titleError =
        _titleTouched && _titleController.text.trim().isEmpty
        ? l10n.reelDetailsTitleRequired
        : null;

    return Scaffold(
      backgroundColor: AppColors.primaryBlueLight,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: isBusy ? null : () => context.pop(),
        ),
        title: Text(
          l10n.reelDetailsTitle,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: AppColors.primaryBlueLight,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: uploadState.phase == ReelUploadPhase.uploading
            ? _UploadingView(
                key: const ValueKey('uploading'),
                progress: uploadState.progress,
              )
            : SingleChildScrollView(
                key: const ValueKey('form'),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: SizedBox(
                          width: 140,
                          height: 200,
                          child: _previewController != null
                              ? FittedBox(
                                  fit: BoxFit.cover,
                                  child: SizedBox(
                                    width: _previewController!.value.size.width,
                                    height:
                                        _previewController!.value.size.height,
                                    child: VideoPlayer(_previewController!),
                                  ),
                                )
                              : const ColoredBox(color: AppColors.primaryDark),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SheetLabel(l10n.reelDetailsTitleLabel),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _titleController,
                            textCapitalization: TextCapitalization.sentences,
                            enabled: !isBusy,
                            onChanged: (_) {
                              if (!_titleTouched) return;
                              setState(() {});
                            },
                            decoration: sheetFieldDecoration(
                              l10n.reelDetailsTitleHint,
                            ),
                          ),
                          if (titleError != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              titleError,
                              style: const TextStyle(
                                color: AppColors.red,
                                fontSize: 12,
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          SheetLabel(l10n.reelDetailsDescriptionLabel),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _descriptionController,
                            maxLines: 3,
                            enabled: !isBusy,
                            decoration: sheetFieldDecoration(
                              l10n.reelDetailsDescriptionHint,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SheetLabel(
                            '${l10n.reelDetailsCategoriesLabel} · ${l10n.reelDetailsCategoriesHint}',
                          ),
                          const SizedBox(height: 8),
                          categoriesAsync.when(
                            loading: () => const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                            error: (e, _) => Row(
                              children: [
                                Expanded(child: Text(l10n.somethingWentWrong)),
                                TextButton(
                                  onPressed: () =>
                                      ref.invalidate(reelCategoriesProvider),
                                  child: Text(l10n.tryAgain),
                                ),
                              ],
                            ),
                            data: (categories) => Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                for (final c in categories)
                                  FilterChip(
                                    label: Text(c.name),
                                    selected: _selectedCategoryIds.contains(
                                      c.id,
                                    ),
                                    selectedColor: AppColors.primaryBlue
                                        .withValues(alpha: 0.15),
                                    checkmarkColor: AppColors.primaryBlue,
                                    onSelected: isBusy
                                        ? null
                                        : (on) => setState(() {
                                            if (!on) {
                                              _selectedCategoryIds.remove(c.id);
                                            } else if (_selectedCategoryIds
                                                    .length <
                                                _maxCategories) {
                                              _selectedCategoryIds.add(c.id);
                                            }
                                          }),
                                  ),
                              ],
                            ),
                          ),
                          if (_submitAttempted &&
                              _selectedCategoryIds.isEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              l10n.reelDetailsCategoriesRequired,
                              style: const TextStyle(
                                color: AppColors.red,
                                fontSize: 12,
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          SheetLabel(l10n.reelDetailsHashtagsLabel),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _hashtagsController,
                            enabled: !isBusy,
                            autocorrect: false,
                            onChanged: (_) => setState(() {}),
                            decoration: sheetFieldDecoration(
                              l10n.reelDetailsHashtagsHint,
                            ),
                          ),
                          if (hashtagCount > _maxHashtags) ...[
                            const SizedBox(height: 6),
                            Text(
                              l10n.reelDetailsHashtagsMax,
                              style: const TextStyle(
                                color: AppColors.red,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (uploadState.phase == ReelUploadPhase.failed &&
                        uploadState.error != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        uploadState.error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.red,
                          fontSize: 13,
                        ),
                      ),
                    ],
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: isBusy ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: AppColors.primaryBlue
                              .withValues(alpha: 0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: isBusy
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                l10n.reelPostButton,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _UploadingView extends StatelessWidget {
  final double progress;

  const _UploadingView({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final percent = (progress * 100).clamp(0, 100).toStringAsFixed(0);

    return ColoredBox(
      color: AppColors.primaryDark,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 120,
              height: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: CircularProgressIndicator(
                      value: progress == 0 ? null : progress,
                      strokeWidth: 6,
                      backgroundColor: Colors.white24,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  Text(
                    '$percent%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Text(
              l10n.reelUploadingTitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.reelUploadingSubtitle,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
