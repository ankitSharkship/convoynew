import 'dart:math' as math;

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../wallet/presentation/utils/currency.dart';
import '../../domain/entities/scratch_card_entity.dart';
import '../state/scratch_cards_notifier.dart';
import 'scratch_card_controller.dart';
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
  final _scratchController = ScratchCardController();
  late final ConfettiController _confettiController;
  bool _revealed = false;
  bool _committing = false;
  bool _committed = false;
  String? _commitError;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  // Fired by ScratchCardWidget both when the user finishes scratching by
  // hand and when the reveal button forces it via the controller — either
  // path counts as the card having been revealed.
  void _handleReveal() {
    setState(() => _revealed = true);
    _commit();
  }

  void _handleRevealButtonTap() {
    if (_revealed) return;
    // Plays over the card while the foil is still fading out, so the
    // reward is visible underneath by the time the burst peaks.
    _confettiController.play();
    _scratchController.reveal();
  }

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
    final l10n = AppLocalizations.of(context)!;
    final rewardValue = double.tryParse(widget.card.rewardRupees ?? '') ?? 0;
    final hasReward = rewardValue > 0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.bottomCenter,
          clipBehavior: Clip.none,
          children: [
            SizedBox(
              width: widget.width,
              height: widget.height,
              child: ScratchCardWidget(
                controller: _scratchController,
                borderRadius: BorderRadius.circular(24),
                brushRadius: 17,
                revealThreshold: 0.5,
                overlay: const ScratchCardFace(),
                onReveal: _handleReveal,
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
            ),
            IgnorePointer(
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirection: -math.pi / 2,
                blastDirectionality: BlastDirectionality.explosive,
                emissionFrequency: 0,
                numberOfParticles: 24,
                maxBlastForce: 18,
                minBlastForce: 8,
                gravity: 0.25,
                shouldLoop: false,
                colors: const [
                  AppColors.primaryBlue,
                  AppColors.green,
                  AppColors.red,
                  AppColors.white,
                ],
              ),
            ),
          ],
        ),
        if (!_revealed) ...[
          const SizedBox(height: 16),
          _RevealButton(
            label: l10n.scratchCardRevealButton,
            onTap: _handleRevealButtonTap,
          ),
        ],
      ],
    );
  }
}

class _RevealButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _RevealButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryBlue,
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
