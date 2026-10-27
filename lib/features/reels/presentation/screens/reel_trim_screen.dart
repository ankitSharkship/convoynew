import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_native_video_trimmer/flutter_native_video_trimmer.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../reel_constants.dart';

/// Lets the user pick an in/out point (max [reelMaxDurationSeconds]) and
/// previews exactly that range on loop. "Next" only invokes the native
/// trimmer when the selection is actually shorter than the source clip —
/// a clip already within the limit that the user leaves untouched is passed
/// straight through, skipping a pointless re-encode.
class ReelTrimScreen extends StatefulWidget {
  final String videoPath;

  const ReelTrimScreen({super.key, required this.videoPath});

  @override
  State<ReelTrimScreen> createState() => _ReelTrimScreenState();
}

class _ReelTrimScreenState extends State<ReelTrimScreen> {
  VideoPlayerController? _controller;
  RangeValues _range = const RangeValues(0, 0);
  double _durationSeconds = 0;
  bool _isTrimming = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final controller = VideoPlayerController.file(File(widget.videoPath));
    try {
      await controller.initialize();
      final duration = controller.value.duration.inMilliseconds / 1000;
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _controller = controller;
        _durationSeconds = duration;
        _range = RangeValues(
          0,
          duration < reelMaxDurationSeconds ? duration : reelMaxDurationSeconds.toDouble(),
        );
      });
      controller.setLooping(false);
      controller.addListener(_loopWithinRange);
      await controller.play();
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
  }

  void _loopWithinRange() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    final position = controller.value.position.inMilliseconds / 1000;
    if (position >= _range.end || position < _range.start) {
      controller.seekTo(Duration(milliseconds: (_range.start * 1000).round()));
    }
  }

  void _onRangeChanged(RangeValues values) {
    // Keeps the selection within reelMaxDurationSeconds by sliding the
    // handle that *wasn't* dragged, rather than refusing the drag outright.
    var start = values.start;
    var end = values.end;
    if (end - start > reelMaxDurationSeconds) {
      if (start != _range.start) {
        end = start + reelMaxDurationSeconds;
      } else {
        start = end - reelMaxDurationSeconds;
      }
    }
    setState(() => _range = RangeValues(start, end));
    _controller?.seekTo(Duration(milliseconds: (start * 1000).round()));
  }

  Future<void> _next() async {
    final fullyUntrimmed =
        _durationSeconds <= reelMaxDurationSeconds &&
        _range.start <= 0.05 &&
        (_durationSeconds - _range.end).abs() <= 0.05;

    if (fullyUntrimmed) {
      if (mounted) {
        context.pushReplacement('/reels/create/details', extra: widget.videoPath);
      }
      return;
    }

    setState(() => _isTrimming = true);
    try {
      final trimmer = VideoTrimmer();
      await trimmer.loadVideo(widget.videoPath);
      final outPath = await trimmer.trimVideo(
        startTimeMs: (_range.start * 1000).round(),
        endTimeMs: (_range.end * 1000).round(),
      );
      if (!mounted) return;
      if (outPath == null) {
        setState(() {
          _isTrimming = false;
          _error = AppLocalizations.of(context)!.somethingWentWrong;
        });
        return;
      }
      context.pushReplacement('/reels/create/details', extra: outPath);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isTrimming = false;
          _error = e.toString();
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_loopWithinRange);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final controller = _controller;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  Expanded(
                    child: Text(
                      l10n.reelTrimTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: controller == null || !controller.value.isInitialized
                    ? const CircularProgressIndicator(color: Colors.white)
                    : AspectRatio(
                        aspectRatio: controller.value.aspectRatio,
                        child: VideoPlayer(controller),
                      ),
              ),
            ),
            if (controller != null && controller.value.isInitialized) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  l10n.reelTrimSelectedDuration(
                    (_range.end - _range.start).toStringAsFixed(1),
                  ),
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppColors.primaryBlue,
                    inactiveTrackColor: Colors.white24,
                    thumbColor: AppColors.primaryBlue,
                    overlayColor: AppColors.primaryBlue.withValues(alpha: 0.2),
                  ),
                  child: RangeSlider(
                    min: 0,
                    max: _durationSeconds,
                    values: _range,
                    onChanged: _onRangeChanged,
                  ),
                ),
              ),
            ],
            if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  _error!,
                  style: const TextStyle(color: AppColors.red, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: controller == null || _isTrimming ? null : _next,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.primaryBlue.withValues(
                      alpha: 0.4,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: _isTrimming
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          l10n.reelTrimNext,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
