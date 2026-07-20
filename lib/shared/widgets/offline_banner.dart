import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/network/network_status_provider.dart';
import '../../l10n/generated/app_localizations.dart';

/// A slim, persistent strip shown at the very top of the app (above every
/// screen, regardless of route) whenever [networkStatusNotifierProvider]
/// reports [NetworkStatus.offline]. Mounted once in `app.dart` via
/// `MaterialApp.router`'s `builder`, so it's global rather than something
/// each screen has to remember to include.
///
/// Deliberately not a Snackbar/dialog: those are one-shot and would have to
/// be re-triggered per failed request. A standing banner instead reflects
/// live connectivity state the whole time the user is offline, and clears
/// itself the moment the next successful request comes back.
class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(networkStatusNotifierProvider);
    final isOffline = status == NetworkStatus.offline;
    final l10n = AppLocalizations.of(context);

    // No SafeArea (and therefore no reserved top-inset padding) at all when
    // online — this widget must collapse to a true zero-height, zero-space
    // no-op so it never competes with each screen's own SafeArea/status-bar
    // handling. SafeArea is only applied *inside* the offline branch, and
    // only after the red background is already in place, so the status-bar
    // strip stays colored instead of showing bare black behind it.
    return AnimatedSize(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeInOut,
      alignment: Alignment.topCenter,
      child: !isOffline
          ? const SizedBox(width: double.infinity, height: 0)
          : Container(
              width: double.infinity,
              color: AppColors.red,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.wifi_off_rounded,
                        size: 16,
                        color: AppColors.white,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          l10n?.networkOfflineBanner ??
                              'No internet connection',
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
