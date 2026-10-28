import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/heatmap_entity.dart';

/// The two-option pill switch: warm-grey track, raised white active pill with a
/// brand-coloured icon and dark-red label, animated.
///
/// Deliberately not a `TabBar` + `TabBarView`: the map under it pans
/// horizontally, and a swipeable `TabBarView` would fight that gesture.
const _trackColor = Color(0xFFEDEAE5);
const _trackBorder = Color(0xFFE0DCD5);
const _activeText = Color(0xFF9A3412);
const _inactiveText = Color(0xFF4A3B35);

class HeatmapKindToggle extends StatelessWidget {
  final HeatmapKind selected;
  final ValueChanged<HeatmapKind> onChanged;

  const HeatmapKindToggle({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isTrucks = selected == HeatmapKind.trucks;

    return Container(
      height: 52,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _trackColor,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: _trackBorder),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            alignment: isTrucks ? Alignment.centerLeft : Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              heightFactor: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            children: [
              _Segment(
                label: l10n.heatmapTabTrucks,
                icon: Icons.local_shipping,
                selected: isTrucks,
                onTap: () => onChanged(HeatmapKind.trucks),
              ),
              _Segment(
                label: l10n.heatmapTabReels,
                icon: Icons.play_circle_outline,
                selected: !isTrucks,
                onTap: () => onChanged(HeatmapKind.reels),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _Segment({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? _activeText : _inactiveText;
    final iconColor = selected ? AppColors.primaryBlue : _inactiveText;
    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 22, color: iconColor),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: color,
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
