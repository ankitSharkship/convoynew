import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/reel_entity.dart';
import '../../domain/entities/reels_feed_key.dart';
import '../state/reels_notifier.dart';
import '../widgets/reel_action_rail.dart';
import '../widgets/reel_avatar.dart';
import '../widgets/reel_comments_sheet.dart';
import '../widgets/reel_formatters.dart';
import '../widgets/reel_source_sheet.dart';

/// How long a reel must play before it counts as a view (or its whole
/// length, if shorter) — the API asks for roughly 2–3 seconds.
const _viewThreshold = Duration(milliseconds: 2500);

/// Full-screen, portrait, vertically-swipeable feed of ready reels
/// (Instagram Reels / YouTube Shorts style), backed by `GET /api/reels`.
///
/// Ported from reels_app's `FeedScreen`: a hand-rolled single-active-player
/// `PageView` rather than a third-party reels carousel package, because that
/// package let a not-yet-visible neighbouring page hijack which reel its
/// shared controller considered "active" — videos never actually paused when
/// swiped away, and the growing pile of concurrently decoding/playing
/// `VideoPlayerController`s is what caused an OOM crash. One active video,
/// no preloading, is simple enough to keep the invariant obviously true.
class ReelsScreen extends ConsumerStatefulWidget {
  const ReelsScreen({super.key});

  @override
  ConsumerState<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends ConsumerState<ReelsScreen> {
  final _pageController = PageController();
  VideoPlayerController? _activeController;
  int _activeIndex = 0;
  bool _isMuted = false;
  List<ReelEntity> _lastItems = [];

  /// Incremented on every activation request; `_runActivation` re-checks it
  /// after each `await` and bails out if a newer request has since started,
  /// so only the newest activation can ever install itself as
  /// [_activeController] — guards against fast swiping starting two
  /// concurrent `initialize()` calls that would otherwise both try to
  /// become the active player.
  int _activationToken = 0;

  /// Activations run strictly one at a time through this chain, because
  /// `initialize()` is what actually allocates the native player — without
  /// serializing, several could sit in `initialize()` concurrently (what
  /// fast swiping does), meaning several native players alive at once.
  Future<void> _activationChain = Future.value();

  /// Controllers swapped out and pending disposal. Already paused (see
  /// [_activate]) so they're silent while waiting to be released.
  final List<VideoPlayerController> _pendingDisposal = [];

  bool _startedFirstActivation = false;
  Timer? _viewTimer;

  /// Whether this screen is actually on screen. The Reels tab lives in the tab
  /// stack, which keeps it mounted (but with tickers off) while another tab is
  /// showing — so without this its video would keep playing, audibly, behind the
  /// Heatmap or Home tab.
  bool _visible = true;

  /// What to do to carry on playing once the screen is visible again — set when
  /// playback was held back or stopped only because the screen was hidden. Null
  /// when the user themselves had paused (then it must stay paused).
  VoidCallback? _resumeWhenVisible;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final visible = TickerMode.valuesOf(context).enabled;
    if (visible != _visible) {
      _visible = visible;
      _onVisibilityChanged();
    }
  }

  void _onVisibilityChanged() {
    final controller = _activeController;
    if (!_visible) {
      if (controller != null && controller.value.isPlaying) {
        // Left before the view threshold? Then it was not a view.
        _viewTimer?.cancel();
        controller.pause();
        final index = _activeIndex;
        final token = _activationToken;
        if (index < _lastItems.length) {
          final reelId = _lastItems[index].id;
          _resumeWhenVisible = () => _startPlayback(reelId, token, controller);
        }
      }
      return;
    }
    final resume = _resumeWhenVisible;
    _resumeWhenVisible = null;
    resume?.call();
    // The first reel is only started while visible, so a feed that finished
    // loading in the background gets going now.
    if (!_startedFirstActivation && mounted) setState(() {});
  }

  /// Plays [controller] and starts counting toward a view of [reelId], unless a
  /// newer activation has replaced it meanwhile.
  Future<void> _startPlayback(
    String reelId,
    int token,
    VideoPlayerController controller,
  ) async {
    if (!mounted || token != _activationToken || _activeController != controller) {
      return;
    }
    await controller.play();
    if (!mounted || token != _activationToken) return;
    _scheduleViewReport(reelId, token, controller);
  }

  @override
  void dispose() {
    _viewTimer?.cancel();
    _activationToken++;
    _activeController?.dispose();
    for (final controller in _pendingDisposal) {
      controller.dispose();
    }
    _pendingDisposal.clear();
    _pageController.dispose();
    super.dispose();
  }

  /// Requests that [index] become the playing reel. Stops the outgoing
  /// reel's audio synchronously (before any `await`) so swiping silences it
  /// immediately, then queues the actual swap.
  void _activate(List<ReelEntity> items, int index) {
    final token = ++_activationToken;
    _viewTimer?.cancel();
    _resumeWhenVisible = null;

    final outgoing = _activeController;
    if (outgoing != null) {
      outgoing.pause();
      _pendingDisposal.add(outgoing);
      _activeController = null;
      if (mounted) setState(() {});
    }

    _activationChain = _activationChain.then(
      (_) => _runActivation(items, index, token),
    );
  }

  Future<void> _runActivation(
    List<ReelEntity> items,
    int index,
    int token,
  ) async {
    if (!mounted || token != _activationToken) return;

    while (_pendingDisposal.isNotEmpty) {
      final stale = _pendingDisposal.removeLast();
      unawaited(stale.dispose().catchError((_) {}));
    }

    if (!mounted || token != _activationToken) return;
    if (index < 0 || index >= items.length) return;
    final reel = items[index];
    final streamUrl = reel.streamUrl;
    if (streamUrl == null) return;
    final url = resolveApiUrl(streamUrl);

    final controller = VideoPlayerController.networkUrl(Uri.parse(url));
    try {
      await controller.initialize();
      if (!mounted || token != _activationToken) {
        await controller.dispose();
        return;
      }
      await controller.setLooping(true);
      await controller.setVolume(_isMuted ? 0 : 1);
      if (!mounted || token != _activationToken) {
        await controller.dispose();
        return;
      }
      setState(() => _activeController = controller);
      if (_visible) {
        await controller.play();
        _scheduleViewReport(reel.id, token, controller);
      } else {
        // Loaded while the screen is hidden: hold it, don't play behind the
        // user's back; it starts when the screen is shown.
        _resumeWhenVisible = () => _startPlayback(reel.id, token, controller);
      }
    } catch (_) {
      if (_activeController == controller) {
        _activeController = null;
        if (mounted) setState(() {});
      }
      await controller.dispose();
    }
  }

  /// Which feed the screen is on: the category chip and/or the heatmap area.
  ReelsFeedKey get _feedKey => ReelsFeedKey(
    categoryId: ref.read(selectedReelCategoryProvider),
    areaCell: ref.read(selectedReelAreaProvider),
  );

  ReelsFeedNotifier get _feedNotifier =>
      ref.read(reelsFeedNotifierProvider(_feedKey).notifier);

  /// Reports one view after the reel has played for [_viewThreshold], unless
  /// the user has swiped away (token changed) before then.
  void _scheduleViewReport(
    String reelId,
    int token,
    VideoPlayerController controller,
  ) {
    final length = controller.value.duration;
    final delay = length > Duration.zero && length < _viewThreshold
        ? length
        : _viewThreshold;
    _viewTimer?.cancel();
    _viewTimer = Timer(delay, () {
      if (!mounted || token != _activationToken) return;
      _feedNotifier.recordView(reelId);
    });
  }

  /// Drops the current player and playback bookkeeping so the next feed
  /// (e.g. after switching category) starts cleanly from its first reel.
  void _resetPlayback() {
    _activationToken++;
    _viewTimer?.cancel();
    _resumeWhenVisible = null;
    if (_pageController.hasClients) _pageController.jumpToPage(0);
    final outgoing = _activeController;
    if (outgoing != null) {
      outgoing.pause();
      _pendingDisposal.add(outgoing);
      _activeController = null;
    }
    _lastItems = [];
    _activeIndex = 0;
    _startedFirstActivation = false;
  }

  void _selectCategory(String? categoryId) {
    if (ref.read(selectedReelCategoryProvider) == categoryId) return;
    setState(_resetPlayback);
    ref.read(selectedReelCategoryProvider.notifier).select(categoryId);
  }

  /// Drops the heatmap-area filter, back to the normal feed (the playback reset
  /// happens in the listener on [selectedReelAreaProvider]).
  void _clearArea() => ref.read(selectedReelAreaProvider.notifier).select(null);

  Future<void> _share(ReelEntity reel) async {
    final l10n = AppLocalizations.of(context)!;
    final streamUrl = reel.streamUrl;
    final text = [
      l10n.reelShareText(reel.title),
      if (streamUrl != null) resolveApiUrl(streamUrl),
    ].join('\n');
    final result = await SharePlus.instance.share(ShareParams(text: text));
    // Some platforms (Android) can't report the outcome, so only an explicit
    // dismissal is treated as "not shared".
    if (result.status != ShareResultStatus.dismissed) {
      _feedNotifier.recordShare(reel.id);
    }
  }

  void _openComments(ReelEntity reel) {
    ReelCommentsSheet.show(
      context,
      reelId: reel.id,
      onCountChanged: (count) {
        if (mounted) _feedNotifier.setCommentCount(reel.id, count);
      },
    );
  }

  void _toggleMute() {
    setState(() => _isMuted = !_isMuted);
    _activeController?.setVolume(_isMuted ? 0 : 1);
  }

  Future<void> _togglePlayPause(int index) async {
    final controller = _activeController;
    if (controller == null || index != _activeIndex) return;
    if (controller.value.isPlaying) {
      await controller.pause();
    } else {
      await controller.play();
    }
    if (mounted && _activeController == controller) setState(() {});
  }

  Widget _statusScaffold(Widget child, {required bool withFab}) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(child: child),
          _buildCategoryChips(),
        ],
      ),
      floatingActionButton: withFab ? _buildFab() : null,
    );
  }

  Widget _buildFab() {
    return FloatingActionButton(
      backgroundColor: AppColors.primaryBlue,
      onPressed: () => openCreateReelFlow(context),
      child: const Icon(Icons.add, color: Colors.white),
    );
  }

  Widget _buildCategoryChips() {
    final l10n = AppLocalizations.of(context)!;
    final categories = ref.watch(reelCategoriesProvider).valueOrNull;
    final selected = ref.watch(selectedReelCategoryProvider);
    final area = ref.watch(selectedReelAreaProvider);
    final hasCategories = categories != null && categories.isNotEmpty;
    if (!hasCategories && area == null) return const SizedBox();

    Widget chip(String label, String? id) {
      final isSelected = selected == id;
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: GestureDetector(
          onTap: () => _selectCategory(id),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryBlue : Colors.black45,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    }

    // The heatmap area the feed is narrowed to: leads the row, tap to clear.
    Widget areaChip(String cell) {
      final label =
          ref
              .watch(
                reelsFeedNotifierProvider(
                  ReelsFeedKey(categoryId: selected, areaCell: cell),
                ),
              )
              .area
              ?.label ??
          l10n.reelsAreaThisArea;
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Semantics(
          button: true,
          label: l10n.reelsAreaShowAll,
          child: GestureDetector(
            onTap: _clearArea,
            child: Container(
              padding: const EdgeInsets.only(left: 10, right: 8),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white70),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.place, size: 15, color: Colors.white),
                  const SizedBox(width: 4),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 150),
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.close, size: 16, color: Colors.white),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 12,
      right: 112,
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          if (area != null) areaChip(area),
          if (hasCategories) ...[
            chip(l10n.reelCategoryAll, null),
            for (final c in categories) chip(c.name, c.id),
          ],
        ],
      ),
    );
  }

  Widget _buildOverlay(ReelEntity reel) {
    final l10n = AppLocalizations.of(context)!;
    const shadow = [Shadow(blurRadius: 8, color: Colors.black)];
    final author = reel.author;
    final location = reel.location?.label;

    return Positioned(
      left: 16,
      right: 76,
      bottom: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (author != null)
            Row(
              children: [
                ReelAvatar(photo: author.profilePhoto, name: author.name, size: 32),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    author.name ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      shadows: shadow,
                    ),
                  ),
                ),
                if (!author.isMe) ...[
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => _feedNotifier.toggleFollow(author.id),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: author.followedByMe
                            ? Colors.black45
                            : AppColors.primaryBlue,
                        border: Border.all(color: Colors.white70),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        author.followedByMe
                            ? l10n.reelFollowing
                            : l10n.reelFollow,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          const SizedBox(height: 8),
          Text(
            reel.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              shadows: shadow,
            ),
          ),
          if (reel.hashtags.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              reel.hashtags.map((h) => '#$h').join(' '),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                shadows: shadow,
              ),
            ),
          ],
          if (location != null) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.place, size: 14, color: Colors.white),
                const SizedBox(width: 2),
                Flexible(
                  child: Text(
                    location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      shadows: shadow,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final category = ref.watch(selectedReelCategoryProvider);
    final area = ref.watch(selectedReelAreaProvider);
    final feedKey = ReelsFeedKey(categoryId: category, areaCell: area);
    final feed = ref.watch(reelsFeedNotifierProvider(feedKey));
    final l10n = AppLocalizations.of(context)!;

    // The area is set from outside (a tap on the Reels heatmap, or its chip):
    // start the new feed cleanly from its first reel, like a category change does.
    ref.listen<String?>(selectedReelAreaProvider, (previous, next) {
      if (previous != next && mounted) setState(_resetPlayback);
    });

    if (feed.items.isEmpty && feed.isLoading) {
      return _statusScaffold(
        const CircularProgressIndicator(color: Colors.white),
        withFab: false,
      );
    }

    if (feed.items.isEmpty && feed.error != null) {
      return _statusScaffold(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.somethingWentWrong,
              style: const TextStyle(color: Colors.white),
            ),
            TextButton(
              onPressed: () => _feedNotifier.refresh(),
              child: Text(l10n.tryAgain),
            ),
          ],
        ),
        withFab: false,
      );
    }

    if (feed.items.isEmpty && feedKey.hasArea) {
      // The hotspot can empty out between the heatmap and here (reels age out of
      // its window, or the only ones are the viewer's own).
      return _statusScaffold(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.reelsAreaEmpty,
              style: const TextStyle(color: Colors.white),
            ),
            TextButton(
              onPressed: _clearArea,
              child: Text(l10n.reelsAreaShowAll),
            ),
          ],
        ),
        withFab: true,
      );
    }

    if (feed.items.isEmpty) {
      return _statusScaffold(
        Text(
          l10n.homeNoReelsYet,
          style: const TextStyle(color: Colors.white),
        ),
        withFab: true,
      );
    }

    final previousItems = _lastItems;
    final isRefresh =
        previousItems.isNotEmpty &&
        (feed.items.length < previousItems.length ||
            feed.items[0].id != previousItems[0].id);
    _lastItems = feed.items;

    if (!_startedFirstActivation && _visible) {
      _startedFirstActivation = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _activate(feed.items, 0);
      });
    } else if (isRefresh) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _activeIndex = 0;
        if (_pageController.hasClients) _pageController.jumpToPage(0);
        _activate(feed.items, 0);
      });
    }

    final activeReel = _activeIndex < feed.items.length
        ? feed.items[_activeIndex]
        : feed.items.first;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () => _feedNotifier.refresh(),
            color: Colors.white,
            backgroundColor: Colors.black87,
            child: PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              itemCount: feed.items.length,
              onPageChanged: (index) {
                setState(() => _activeIndex = index);
                _activate(feed.items, index);
                if (index >= feed.items.length - 3) {
                  _feedNotifier.loadNextPage();
                }
              },
              itemBuilder: (context, index) {
                final reel = feed.items[index];
                final isActive =
                    index == _activeIndex && _activeController != null;
                return GestureDetector(
                  onTap: () => _togglePlayPause(index),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (isActive)
                        FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            width: _activeController!.value.size.width,
                            height: _activeController!.value.size.height,
                            child: VideoPlayer(_activeController!),
                          ),
                        )
                      else if (reel.thumbnailUrl != null)
                        Image.network(
                          reel.thumbnailUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const SizedBox(),
                        )
                      else
                        const SizedBox(),
                      if (index == _activeIndex && _activeController == null)
                        const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        ),
                      _buildOverlay(reel),
                    ],
                  ),
                );
              },
            ),
          ),
          // Sits above the create-reel FAB (bottom-right) rather than under it.
          Positioned(
            right: 12,
            bottom: 104,
            child: ReelActionRail(
              reel: activeReel,
              onLike: () => _feedNotifier.toggleLike(activeReel.id),
              onComment: () => _openComments(activeReel),
              onShare: () => _share(activeReel),
            ),
          ),
          _buildCategoryChips(),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 12,
            child: Row(
              children: [
                Material(
                  color: Colors.black45,
                  shape: const CircleBorder(),
                  child: IconButton(
                    icon: Icon(
                      _isMuted ? Icons.volume_off : Icons.volume_up,
                      color: Colors.white,
                    ),
                    onPressed: _toggleMute,
                  ),
                ),
                const SizedBox(width: 8),
                Material(
                  color: Colors.black45,
                  shape: const CircleBorder(),
                  child: IconButton(
                    icon: feed.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.refresh, color: Colors.white),
                    onPressed: feed.isLoading
                        ? null
                        : () => _feedNotifier.refresh(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFab(),
    );
  }
}
