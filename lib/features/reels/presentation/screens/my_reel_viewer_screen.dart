import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/reel_entity.dart';
import '../state/reels_notifier.dart';
import '../widgets/reel_action_rail.dart';
import '../widgets/reel_comments_sheet.dart';
import '../widgets/reel_delete.dart';
import '../widgets/reel_formatters.dart';

/// Full-screen player for one of the signed-in user's own ready reels, opened
/// from My Uploads. No feed behind it, no like button (it's their own reel) and
/// no view reporting; comments, share and delete are available.
class MyReelViewerScreen extends ConsumerStatefulWidget {
  final ReelEntity reel;

  const MyReelViewerScreen({super.key, required this.reel});

  @override
  ConsumerState<MyReelViewerScreen> createState() => _MyReelViewerScreenState();
}

class _MyReelViewerScreenState extends ConsumerState<MyReelViewerScreen> {
  VideoPlayerController? _controller;
  late ReelEntity _reel = widget.reel;
  bool _isMuted = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    final streamUrl = _reel.streamUrl;
    if (streamUrl == null) {
      setState(() => _failed = true);
      return;
    }
    final controller = VideoPlayerController.networkUrl(
      Uri.parse(resolveApiUrl(streamUrl)),
    );
    try {
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      await controller.setLooping(true);
      await controller.play();
      setState(() => _controller = controller);
    } catch (_) {
      await controller.dispose();
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _togglePlayPause() async {
    final controller = _controller;
    if (controller == null) return;
    if (controller.value.isPlaying) {
      await controller.pause();
    } else {
      await controller.play();
    }
    if (mounted) setState(() {});
  }

  void _toggleMute() {
    setState(() => _isMuted = !_isMuted);
    _controller?.setVolume(_isMuted ? 0 : 1);
  }

  Future<void> _share() async {
    final l10n = AppLocalizations.of(context)!;
    final streamUrl = _reel.streamUrl;
    final text = [
      l10n.reelShareText(_reel.title),
      if (streamUrl != null) resolveApiUrl(streamUrl),
    ].join('\n');
    final result = await SharePlus.instance.share(ShareParams(text: text));
    if (result.status == ShareResultStatus.dismissed) {
      return;
    }
    try {
      final count = await ref.read(shareReelUseCaseProvider).execute(_reel.id);
      if (mounted) setState(() => _reel = _reel.copyWith(shareCount: count));
    } catch (_) {}
  }

  void _openComments() {
    ReelCommentsSheet.show(
      context,
      reelId: _reel.id,
      onCountChanged: (count) {
        if (!mounted) return;
        setState(() => _reel = _reel.copyWith(commentCount: count));
      },
    );
  }

  Future<void> _delete() async {
    _controller?.pause();
    final deleted = await confirmAndDeleteReel(context, ref, _reel);
    if (!mounted) return;
    if (deleted) {
      context.pop();
    } else {
      _controller?.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final location = _reel.location?.label;
    const shadow = [Shadow(blurRadius: 8, color: Colors.black)];

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            onTap: _togglePlayPause,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (controller != null)
                  FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: controller.value.size.width,
                      height: controller.value.size.height,
                      child: VideoPlayer(controller),
                    ),
                  )
                else if (_reel.thumbnailUrl != null)
                  Image.network(
                    _reel.thumbnailUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const SizedBox(),
                  ),
                if (controller == null && !_failed)
                  const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                if (_failed)
                  Center(
                    child: Text(
                      AppLocalizations.of(context)!.uploadsReelNotPlayable,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                if (controller != null && !controller.value.isPlaying)
                  const Center(
                    child: Icon(
                      Icons.play_arrow_rounded,
                      size: 72,
                      color: Colors.white70,
                    ),
                  ),
              ],
            ),
          ),
          Positioned(
            left: 16,
            right: 76,
            bottom: 24,
            child: SafeArea(
              top: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _reel.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      shadows: shadow,
                    ),
                  ),
                  if (_reel.hashtags.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      _reel.hashtags.map((h) => '#$h').join(' '),
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
            ),
          ),
          Positioned(
            right: 12,
            bottom: 40,
            child: SafeArea(
              top: false,
              child: ReelActionRail(
                reel: _reel,
                onComment: _openComments,
                onShare: _share,
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 12,
            right: 12,
            child: Row(
              children: [
                _CircleButton(
                  icon: Icons.arrow_back,
                  onPressed: () => context.pop(),
                ),
                const Spacer(),
                _CircleButton(
                  icon: _isMuted ? Icons.volume_off : Icons.volume_up,
                  onPressed: _toggleMute,
                ),
                const SizedBox(width: 8),
                _CircleButton(icon: Icons.delete_outline, onPressed: _delete),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _CircleButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black45,
      shape: const CircleBorder(),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
      ),
    );
  }
}
