import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../rendering/heat_field.dart';

/// "Fewer ▬▬▬ More" colour bar, drawn from the same gradient as the heat layer
/// so the two can't drift apart.
class HeatmapLegend extends StatelessWidget {
  const HeatmapLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    const labelStyle = TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: AppColors.textSecondary,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.heatmapLegendLow, style: labelStyle),
            const SizedBox(width: 8),
            Container(
              width: 84,
              height: 8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                gradient: LinearGradient(
                  colors: [
                    for (final stop in heatGradient.skip(1))
                      Color.fromRGBO(
                        stop[1].round(),
                        stop[2].round(),
                        stop[3].round(),
                        // Over a white card the gradient's own alpha ramp
                        // already reads low -> high; keep it fully visible.
                        0.5 + 0.5 * stop[4],
                      ),
                  ],
                  stops: [for (final stop in heatGradient.skip(1)) stop[0]],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(l10n.heatmapLegendHigh, style: labelStyle),
          ],
        ),
      ),
    );
  }
}
