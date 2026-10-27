import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/utils/truck_type_i18n.dart';
import '../../../../shared/utils/truck_type_image.dart';

/// Sentinel returned by [TruckTypeSheet] when the user taps "Any" — lets
/// callers tell an explicit "clear the filter" choice apart from just
/// dismissing the sheet without picking anything (which also resolves the
/// future with null). No real truck type value is ever empty, so this
/// can't collide.
const anyTruckTypeValue = '';

/// Bottom sheet for picking a truck type — a grid of illustrated cards
/// instead of a plain text dropdown.
class TruckTypeSheet extends StatelessWidget {
  final String? selected;

  /// Shows a leading "Any" card that clears the truck-type filter —
  /// only meaningful for the search-trucks filter, where no type at all
  /// is a valid choice. The add-truck form always requires a specific
  /// type, so it must never pass this.
  final bool showAnyOption;

  const TruckTypeSheet({
    super.key,
    required this.selected,
    this.showAnyOption = false,
  });

  static Future<String?> show(
    BuildContext context, {
    String? selected,
    bool showAnyOption = false,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          TruckTypeSheet(selected: selected, showAnyOption: showAnyOption),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.searchTruckTypeLabel,
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: AppColors.chipBackground,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 18,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Flexible(
              child: GridView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.8,
                ),
                itemCount: truckTypes.length + (showAnyOption ? 1 : 0),
                itemBuilder: (context, i) {
                  if (showAnyOption && i == 0) {
                    return _TruckTypeCard(
                      label: l10n.resultsAny,
                      imagePath: 'assets/trucks/any.webp',
                      selected: selected == null,
                      onTap: () => Navigator.pop(context, anyTruckTypeValue),
                    );
                  }
                  final type = truckTypes[showAnyOption ? i - 1 : i];
                  return _TruckTypeCard(
                    label: truckTypeLabel(context, type),
                    imagePath: truckTypeImagePath(type),
                    selected: type == selected,
                    onTap: () => Navigator.pop(context, type),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TruckTypeCard extends StatelessWidget {
  final String label;
  final String? imagePath;
  final bool selected;
  final VoidCallback onTap;

  const _TruckTypeCard({
    required this.label,
    required this.imagePath,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? AppColors.primaryBlue : AppColors.border,
            width: selected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: selected ? 0.1 : 0.04),
              blurRadius: selected ? 16 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(17),
                      ),
                      child: imagePath != null
                          ? Image.asset(imagePath!, fit: BoxFit.cover)
                          : Container(
                              color: AppColors.chipBackground,
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.local_shipping_outlined,
                                size: 32,
                                color: AppColors.textTertiary,
                              ),

                            ),
                    ),
                  ),
                  if (selected)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryBlue,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          size: 15,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                  color: selected
                      ? AppColors.primaryBlue
                      : AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
