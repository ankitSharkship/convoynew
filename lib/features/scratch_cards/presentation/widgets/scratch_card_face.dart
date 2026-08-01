import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';

/// The single "unscratched" card design — used identically for the small
/// tile on the wallet's Scratch Cards grid and, enlarged, as the actual
/// foil in [ScratchCardWidget]'s `overlay`, so a card looks exactly the
/// same before and after it grows into the centered, scratchable view.
/// Sizes itself proportionally to whatever box it's given via
/// [LayoutBuilder], since those two placements are very different sizes.
class ScratchCardFace extends StatelessWidget {
  /// Fraction of the available width used for the "Scratch Here" font size.
  /// Smaller on the wallet grid's tiny tiles than on the enlarged card, so
  /// the same design doesn't read as oversized in the list.
  final double textScale;

  const ScratchCardFace({super.key, this.textScale = 0.105});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.heroGradientStart,
            AppColors.heroGradientMid,
            AppColors.heroGradientEnd,
          ],
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final scale = constraints.maxWidth;
          return Stack(
            fit: StackFit.expand,
            children: [
              const Positioned.fill(child: CustomPaint(painter: _SunburstPainter())),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.sell_outlined,
                      color: AppColors.white,
                      size: scale * 0.22,
                    ),
                    SizedBox(height: scale * 0.06),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: scale * 0.08),
                      child: Text(
                        l10n.walletScratchCardScratchHint,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: scale * textScale,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                    SizedBox(height: scale * 0.05),
                    Container(
                      width: scale * 0.16,
                      height: 2,
                      color: AppColors.white.withValues(alpha: 0.6),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Faint alternating rays radiating from the card's center, matching the
/// "sunburst" look of a classic scratch-card design — drawn as a live
/// widget (not a static asset) so it can be reused at any size.
class _SunburstPainter extends CustomPainter {
  const _SunburstPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.longestSide; // long enough to always reach the corners
    const rayCount = 28;
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.07);

    for (var i = 0; i < rayCount; i += 2) {
      final angle = (2 * math.pi / rayCount) * i;
      final halfWidth = (math.pi / rayCount) * 0.5;
      final p1 = center +
          Offset(radius * math.cos(angle - halfWidth), radius * math.sin(angle - halfWidth));
      final p2 = center +
          Offset(radius * math.cos(angle + halfWidth), radius * math.sin(angle + halfWidth));
      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..lineTo(p1.dx, p1.dy)
        ..lineTo(p2.dx, p2.dy)
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SunburstPainter oldDelegate) => false;
}
