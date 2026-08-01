import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/scratch_card_entity.dart';
import 'scratch_card_reveal.dart';

String scratchCardHeroTag(String cardId) => 'scratch-card-$cardId';

/// Pushes the enlarged, centered scratch card on top of the current screen
/// with a dimmed backdrop — the [Hero] tag shared with the grid tile that
/// triggered this drives the "grows from its small tile into the middle of
/// the screen" flight animation automatically.
///
/// Pushed on the *local* (branch) navigator via `rootNavigator: false` and
/// always popped using this route's own context — mixing navigators here is
/// exactly what caused the reward-dialog crash fixed earlier.
Future<void> showScratchCardOverlay(BuildContext context, ScratchCardEntity card) {
  return Navigator.of(context, rootNavigator: false).push(
    PageRouteBuilder(
      opaque: false,
      barrierDismissible: true,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return FadeTransition(
          opacity: animation,
          child: _ScratchCardOverlay(card: card),
        );
      },
    ),
  );
}

class _ScratchCardOverlay extends StatelessWidget {
  final ScratchCardEntity card;

  const _ScratchCardOverlay({required this.card});

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(color: Colors.black.withValues(alpha: 0.65)),
            ),
          ),
          Center(
            child: Hero(
              tag: scratchCardHeroTag(card.id),
              // Without this, Hero's default flight shuttle reuses the
              // destination child (ScratchCardReveal) inside a temporary
              // overlay for the animation, then again at rest — mounting it
              // twice and firing its reward-fetching initState twice, which
              // scratches the card server-side before the user even sees
              // it. A static, side-effect-free placeholder during the
              // flight avoids that; the real widget is still built exactly
              // once, for the route's actual resting content.
              flightShuttleBuilder: (_, _, _, _, _) =>
                  const _ScratchCardFlightPlaceholder(),
              child: Material(
                color: Colors.transparent,
                child: ScratchCardReveal(card: card),
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

/// Stands in for [ScratchCardReveal] only while the Hero is mid-flight —
/// same foil look, but no Scratcher/network side effects, so it's safe to
/// mount and discard as many times as the flight animation needs to.
class _ScratchCardFlightPlaceholder extends StatelessWidget {
  const _ScratchCardFlightPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.heroGradientStart,
              AppColors.heroGradientMid,
              AppColors.heroGradientEnd,
            ],
          ),
        ),
      ),
    );
  }
}
