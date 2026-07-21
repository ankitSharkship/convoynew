import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../profile/presentation/state/profile_notifier.dart';
import '../state/kyc_notifier.dart';

/// Shown right after [FaceCaptureScreen] auto-captures a photo, so the user
/// can confirm it (updating their profile photo locally) or retake it
/// before it's used anywhere.
class FaceReviewScreen extends ConsumerStatefulWidget {
  final File imageFile;

  /// Route to continue to once the photo is confirmed and the profile
  /// photo has been updated. Defaults to going back to `/profile` (the
  /// standalone testing entry point); the KYC flow passes `/post` instead.
  final String? nextRoute;

  const FaceReviewScreen({
    super.key,
    required this.imageFile,
    this.nextRoute,
  });

  @override
  ConsumerState<FaceReviewScreen> createState() => _FaceReviewScreenState();
}

class _FaceReviewScreenState extends ConsumerState<FaceReviewScreen> {
  bool _saving = false;
  String? _error;

  void _retake() {
    // Replaces (rather than pops back to) the capture screen so a fresh
    // CameraController is created — the one behind this screen was already
    // stopped after taking this photo. Carries the same nextRoute along so
    // a retake doesn't lose track of where to go next.
    context.pushReplacement('/face_capture', extra: widget.nextRoute);
  }

  Future<void> _confirm() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final notifier = ref.read(profileNotifierProvider.notifier);
      await notifier.updatePhoto(widget.imageFile.path);
      await notifier.uploadPhoto(widget.imageFile);

      final nextRoute = widget.nextRoute;
      if (nextRoute != null) {
        // This upload is meant to complete KYC step 2 (the photo upload
        // endpoint is reused for that server-side) — don't just assume it
        // worked. Re-check the authoritative status before letting the
        // user through to `nextRoute` (e.g. `/post`); the upload response
        // itself doesn't confirm the KYC side effect actually happened.
        final userId = await ref.read(tokenStorageProvider).getUserId();
        final status = userId != null
            ? await ref.read(getKycStatusUseCaseProvider).execute(userId)
            : null;
        if (status?.isApproved != true) {
          if (!mounted) return;
          setState(() {
            _saving = false;
            _error = AppLocalizations.of(context)!.faceReviewVerificationFailed;
          });
          return;
        }
        ref.invalidate(profileNotifierProvider);
      }

      if (!mounted) return;
      if (nextRoute != null) {
        context.pushReplacement(nextRoute);
      } else {
        context.go('/profile');
      }
    } catch (e) {
      debugPrint('Failed to update profile photo: $e');
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _saving
            ? _VerifyingView(key: const ValueKey('verifying'), imageFile: widget.imageFile)
            : _ReviewView(
                key: const ValueKey('review'),
                imageFile: widget.imageFile,
                errorMessage: _error,
                onRetake: _retake,
                onConfirm: _confirm,
              ),
      ),
    );
  }
}

// ── Review content ───────────────────────────────────────────────────────

class _ReviewView extends StatelessWidget {
  final File imageFile;
  final String? errorMessage;
  final VoidCallback onRetake;
  final VoidCallback onConfirm;

  const _ReviewView({
    super.key,
    required this.imageFile,
    this.errorMessage,
    required this.onRetake,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.file(imageFile, fit: BoxFit.cover),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0),
                  Colors.black.withValues(alpha: 0.85),
                ],
              ),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 40, 24, 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.faceReviewTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (errorMessage != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.red,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 52,
                            child: OutlinedButton(
                              onPressed: onRetake,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.white,
                                side: const BorderSide(color: AppColors.white),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Text(
                                l10n.faceReviewRetake,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 52,
                            child: ElevatedButton(
                              onPressed: onConfirm,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryBlue,
                                foregroundColor: AppColors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                l10n.faceReviewConfirm,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Verifying animation ──────────────────────────────────────────────────

/// Full-screen "we're checking your photo" moment shown while the upload
/// is in flight — a magnifying glass orbits the captured photo while pulse
/// rings scan outward behind it.
class _VerifyingView extends StatefulWidget {
  final File imageFile;

  const _VerifyingView({super.key, required this.imageFile});

  @override
  State<_VerifyingView> createState() => _VerifyingViewState();
}

class _VerifyingViewState extends State<_VerifyingView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ColoredBox(
      color: AppColors.primaryDark,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 180,
              height: 180,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _ScanRingsPainter(progress: _controller.value),
                    child: child,
                  );
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.file(
                        widget.imageFile,
                        width: 110,
                        height: 110,
                        fit: BoxFit.cover,
                      ),
                    ),
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, _) {
                        final angle = _controller.value * 2 * math.pi;
                        return Transform.translate(
                          offset: Offset(
                            58 * math.cos(angle),
                            58 * math.sin(angle),
                          ),
                          child: Transform.rotate(
                            angle: math.pi / 4,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primaryBlue,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryBlue.withValues(
                                      alpha: 0.5,
                                    ),
                                    blurRadius: 12,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.search,
                                size: 20,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              l10n.faceReviewVerifyingTitle,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                l10n.faceReviewVerifyingMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScanRingsPainter extends CustomPainter {
  final double progress;

  _ScanRingsPainter({required this.progress});

  static const _phases = [0.0, 0.33, 0.66];

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final maxRadius = size.width / 2;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (final phase in _phases) {
      final t = (progress + phase) % 1.0;
      final opacity = (1 - t).clamp(0.0, 1.0);
      paint.color = AppColors.primaryBlue.withValues(alpha: opacity * 0.55);
      canvas.drawCircle(center, maxRadius * t, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ScanRingsPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
