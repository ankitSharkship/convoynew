import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';

/// Small preview card shown below the search form — tapping it opens the
/// real, live [TruckMapScreen]. Fills whatever space its parent gives it
/// (wrap in `Expanded`/`SizedBox` to size it).
///
/// Backed by a pre-blurred static asset (`truck_map_blurred.png`, generated
/// once offline from `truck_map.png`) rather than a live map + runtime blur
/// filter — this card is purely decorative, so there's no reason to pay for
/// network tile fetches, a live flutter_map engine instance, or a
/// per-frame BackdropFilter just to show a teaser.
class MiniMapPreview extends StatelessWidget {
  const MiniMapPreview({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: GestureDetector(
        onTap: () => context.push('/truck-map'),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/truck_map_blurred.png',
              fit: BoxFit.cover,
            ),
            Container(color: Colors.black.withValues(alpha: 0.32)),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.map_outlined,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l10n.truckMapPreviewTitle,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.truckMapPreviewSubtitle,
                    style: TextStyle(
                      color: AppColors.white.withValues(alpha: 0.85),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      l10n.truckMapPreviewCta,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
