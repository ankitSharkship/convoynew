import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/scratch_card_entity.dart';
import 'scratch_card_face.dart';
import 'scratch_card_overlay.dart';

/// A small preview in the wallet grid — tapping an unscratched card opens
/// [showScratchCardOverlay], which grows this same [Hero] into the
/// enlarged, actually-scratchable card centered on screen. Uses the exact
/// same [ScratchCardFace] design as the enlarged foil, just smaller, so
/// there's no visual switch between the dormant and opened states.
/// Scratched/expired cards are just static tiles, not tappable.
class ScratchCardGridTile extends StatelessWidget {
  final ScratchCardEntity card;

  const ScratchCardGridTile({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isUnscratched = card.status == ScratchCardStatus.unscratched;

    final tile = isUnscratched
        ? const ScratchCardFace(textScale: 0.07)
        : Container(
            decoration: const BoxDecoration(color: AppColors.white),
            padding: const EdgeInsets.all(14),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    card.status == ScratchCardStatus.scratched
                        ? Icons.check_circle
                        : Icons.timer_off_outlined,
                    size: 36,
                    color: card.status == ScratchCardStatus.scratched
                        ? AppColors.green
                        : AppColors.textTertiary,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    card.status == ScratchCardStatus.scratched
                        ? ((double.tryParse(card.rewardRupees ?? '') ?? 0) > 0
                              ? '₹${card.rewardRupees}'
                              : l10n.walletScratchCardNoReward)
                        : l10n.walletScratchCardExpired,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          );

    return Hero(
      tag: scratchCardHeroTag(card.id),
      child: Material(
        type: MaterialType.transparency,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: isUnscratched
              ? InkWell(
                  onTap: () => showScratchCardOverlay(context, card),
                  child: tile,
                )
              : tile,
        ),
      ),
    );
  }
}
