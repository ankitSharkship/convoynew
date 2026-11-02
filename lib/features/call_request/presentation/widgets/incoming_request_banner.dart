import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../wallet/presentation/utils/currency.dart';
import '../../domain/entities/call_request_entity.dart';
import '../state/call_request_notifier.dart';
import 'incoming_request_sheet.dart';

/// The driver's "1:1 Video Request Pending" pill that floats at the bottom of
/// Home, just above the navigation bar. Tapping it opens the oldest waiting
/// request for review; once everything is answered, accepted requests show as
/// "1:1 call ready to start" so the driver can find their way back to Start. Silent when there is nothing waiting (or the queue can't
/// be loaded): it is an extra, never an error screen.
///
/// It only watches the queue while Home is the visible tab, so a hidden Home
/// doesn't keep polling the server. Whether to show it at all
/// (FeatureFlags.oneToOneEnabled) is the caller's decision, so that a build with
/// the feature off never even creates it.
class IncomingRequestBanner extends ConsumerStatefulWidget {
  const IncomingRequestBanner({super.key});

  @override
  ConsumerState<IncomingRequestBanner> createState() =>
      _IncomingRequestBannerState();
}

class _IncomingRequestBannerState extends ConsumerState<IncomingRequestBanner> {
  bool _opening = false;

  void _openSheet(String requestId) {
    IncomingRequestSheet.show(context, requestId);
  }

  @override
  Widget build(BuildContext context) {
    // Home is hidden behind another tab: show nothing and stop watching the queue.
    if (!TickerMode.valuesOf(context).enabled) {
      return const SizedBox.shrink();
    }

    // A tapped "new request" push asks for that request to be opened: do it as
    // soon as Home is actually on screen.
    final requested = ref.watch(pendingReviewRequestProvider);
    if (requested != null && !_opening) {
      _opening = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _opening = false;
        if (!mounted) return;
        ref.read(pendingReviewRequestProvider.notifier).clear();
        _openSheet(requested);
      });
    }

    final queue =
        ref.watch(incomingCallRequestsNotifierProvider).valueOrNull ??
        const <CallRequestEntity>[];
    final pending = queue.where((r) => r.status == CallStatus.pending).toList();
    final ready = queue.where((r) => r.status == CallStatus.accepted).toList();
    // Requests still waiting for an answer come first; once there are none, the
    // accepted ones are offered as "ready to start".
    final isReady = pending.isEmpty;
    final waiting = isReady ? ready : pending;
    if (waiting.isEmpty) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    final first = waiting.first;
    final title = isReady
        ? l10n.oneToOneBannerReadyTitle
        : l10n.oneToOneBannerTitle;
    final name = (first.requester.name ?? '').trim().isEmpty
        ? l10n.oneToOneRequesterFallback
        : first.requester.name!;

    return Semantics(
      button: true,
      label: waiting.length > 1
          ? '${l10n.oneToOneBannerTitle}, ${l10n.oneToOneBannerMore(waiting.length - 1)}'
          : l10n.oneToOneBannerTitle,
      child: Material(
        color: AppColors.primaryDark,
        elevation: 6,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () => _openSheet(first.id),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            child: Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.videocam_outlined,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    Positioned(
                      top: waiting.length > 1 ? -6 : -3,
                      right: waiting.length > 1 ? -6 : -3,
                      child: Container(
                        constraints: BoxConstraints(
                          minWidth: waiting.length > 1 ? 20 : 12,
                          minHeight: waiting.length > 1 ? 20 : 12,
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: waiting.length > 1 ? 5 : 0,
                        ),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.primaryDark,
                            width: 2,
                          ),
                        ),
                        // How many requests are waiting, when it's more than one.
                        child: waiting.length > 1
                            ? Text(
                                '${waiting.length}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.white,
                                ),
                              )
                            : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Scales down on a narrow screen rather than being cut off.
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          title,
                          maxLines: 1,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 3),
                      // Name • amount. On a narrow screen the amount simply moves
                      // to the next line: nothing here is ever cut off.
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 6,
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.white.withValues(alpha: 0.75),
                            ),
                          ),
                          Text(
                            '•',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.white.withValues(alpha: 0.75),
                            ),
                          ),
                          Text(
                            l10n.oneToOneBannerOffered(
                              formatRupees(first.amount),
                            ),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isReady
                            ? l10n.oneToOneBannerStart
                            : l10n.oneToOneBannerReview,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(width: 3),
                      Icon(
                        isReady ? Icons.videocam : Icons.arrow_forward,
                        size: 15,
                        color: AppColors.white,
                      ),
                    ],
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
