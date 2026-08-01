import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../wallet/presentation/utils/currency.dart';
import '../../domain/entities/scratch_card_entity.dart';
import '../state/scratch_cards_notifier.dart';
import 'scratch_card_face.dart';
import 'scratch_card_widget.dart';

/// The actual scratch-off card. The backend now precomputes and attaches
/// each card's `rewardRupees` at issuance time, so the number is already
/// known from [card] the instant this widget builds — no fetch, no loading
/// state for the amount itself. Scratching just physically uncovers a
/// number that was there all along.
///
/// The scratch/commit API call (marks the card scratched + credits the
/// wallet) only fires once the user actually scratches past the reveal
/// threshold — not when this widget first appears — so opening the card
/// doesn't silently consume it, and the wallet grid behind an open overlay
/// doesn't change until the user has actually engaged with this card.
///
/// Reused as-is both inside the wallet's enlarge-to-center overlay and on
/// the post-truck-success interstitial, which is why title/subtitle chrome
/// around the card lives in the caller, not here — only the card itself and
/// its scratch mechanics do.
class ScratchCardReveal extends ConsumerStatefulWidget {
  final ScratchCardEntity card;
  final double width;
  final double height;
  final void Function(ScratchResultEntity result)? onRevealResult;

  const ScratchCardReveal({
    super.key,
    required this.card,
    this.width = 260,
    this.height = 340,
    this.onRevealResult,
  });

  @override
  ConsumerState<ScratchCardReveal> createState() => _ScratchCardRevealState();
}

class _ScratchCardRevealState extends ConsumerState<ScratchCardReveal> {
  bool _committing = false;
  bool _committed = false;
  String? _commitError;

  Future<void> _commit() async {
    if (_committed || _committing) return;
    setState(() {
      _committing = true;
      _commitError = null;
    });
    try {
      final result = await ref
          .read(scratchCardsNotifierProvider.notifier)
          .scratch(widget.card.id);
      if (!mounted) return;
      setState(() {
        _committing = false;
        _committed = true;
      });
      widget.onRevealResult?.call(result);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _committing = false;
        _commitError = ApiException.messageFor(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final rewardValue = double.tryParse(widget.card.rewardRupees ?? '') ?? 0;
    final hasReward = rewardValue > 0;

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: ScratchCardWidget(
        borderRadius: BorderRadius.circular(24),
        brushRadius: 17,
        revealThreshold: 0.5,
        overlay: const ScratchCardFace(),
        onReveal: _commit,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: AppColors.white,
          alignment: Alignment.center,
          child: _RevealedContent(
            hasReward: hasReward,
            rewardRupees: widget.card.rewardRupees,
            committing: _committing,
            commitError: _commitError,
            onRetry: _commit,
          ),
        ),
      ),
    );
  }
}

class _RevealedContent extends StatelessWidget {
  final bool hasReward;
  final String? rewardRupees;
  final bool committing;
  final String? commitError;
  final VoidCallback onRetry;

  const _RevealedContent({
    required this.hasReward,
    required this.rewardRupees,
    required this.committing,
    required this.commitError,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          hasReward ? Icons.celebration : Icons.sentiment_satisfied_alt,
          size: 56,
          color: hasReward ? AppColors.primaryBlue : AppColors.textTertiary,
        ),
        const SizedBox(height: 12),
        if (hasReward)
          Text(
            formatRupees(rewardRupees!),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              l10n.postScratchCardNoRewardTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        // The number above is already real and final — this row only
        // reflects whether it's been persisted server-side (wallet
        // credited, card marked scratched) yet, never gates the display.
        if (committing) ...[
          const SizedBox(height: 10),
          const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ] else if (commitError != null) ...[
          const SizedBox(height: 6),
          Text(
            commitError!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.red, fontSize: 11),
          ),
          TextButton(onPressed: onRetry, child: Text(l10n.tryAgain)),
        ],
      ],
    );
  }
}
