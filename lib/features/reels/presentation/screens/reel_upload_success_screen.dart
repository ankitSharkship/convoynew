import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../state/my_uploads_notifier.dart';
import '../state/reels_notifier.dart';

/// Mirrors PostSuccessScreen's shell (check icon, title/subtitle, single
/// CTA) for the same "you're done, here's what's next" moment after a reel
/// upload completes.
class ReelUploadSuccessScreen extends ConsumerWidget {
  const ReelUploadSuccessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: AppColors.greenLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 48,
                  color: AppColors.green,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.reelUploadSuccessTitle,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.reelUploadSuccessSubtitle,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {
                  ref.invalidate(reelsFeedNotifierProvider);
                  ref.invalidate(myUploadsProvider);
                  context.go('/reels');
                },
                icon: const Icon(Icons.play_circle_outline, size: 18),
                label: Text(l10n.reelBackToReels),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
