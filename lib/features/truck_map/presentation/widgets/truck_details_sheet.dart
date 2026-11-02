import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/feature_flags.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/utils/truck_type_i18n.dart';
import '../../../../shared/widgets/wheel_number_picker.dart';
import '../../../contacts/presentation/state/contacts_sync_notifier.dart';
import '../../../call_request/presentation/state/call_request_notifier.dart';
import '../../../call_request/presentation/widgets/request_one_to_one_sheet.dart';
import '../../../contacts/presentation/widgets/mutual_contacts_sheet.dart';
import '../../../search/domain/entities/truck_search_result_entity.dart';

String _maskVehicleNumber(String number) {
  final buffer = StringBuffer();
  for (var i = 0; i < number.length; i++) {
    buffer.write(i.isEven ? number[i] : '*');
  }
  return buffer.toString();
}

Future<void> _callNumber(BuildContext context, String phone) async {
  final uri = Uri(scheme: 'tel', path: phone);
  final launched = await canLaunchUrl(uri) && await launchUrl(uri);
  if (!launched && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.resultsCallDialerError),
      ),
    );
  }
}

/// Bottom sheet shown when a marker on the truck map is tapped — same
/// per-post fields as the search results card (poster, contact, the route from
/// origin through every destination, truck type/capacity/size/number, mutual
/// contacts), just laid out for a sheet.
class TruckDetailsSheet extends ConsumerWidget {
  final TruckSearchResultEntity result;

  const TruckDetailsSheet({super.key, required this.result});

  static Future<void> show(
    BuildContext context,
    TruckSearchResultEntity result,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      // Above the bottom navigation when opened from a tab, not inside it.
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TruckDetailsSheet(result: result),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    // Same rule as the search card: mutuals are only shown once contacts are
    // synced, otherwise the number can't be backed up by anything.
    final hasContactsPermission =
        ref.watch(hasContactsPermissionProvider).valueOrNull ?? false;
    final showMutuals = result.mutualsCount > 0 && hasContactsPermission;
    final displayName = result.displayContactName;
    final origin = fullLocation(
      result.origin,
      result.originLocation.city,
      result.originLocation.state,
      result.originLocation.pincode,
    );
    final capacity = result.capacity > 0
        ? l10n.capacityTon(result.capacity)
        : null;
    // You can't ask yourself for a call: hide the button on your own post.
    final isOwnPost =
        ref.watch(currentUserIdProvider).valueOrNull == result.userId;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
                  _UserAvatar(photoUrl: result.userPhoto),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (result.hasAlternateContact)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              l10n.resultsPostedBy(result.userName),
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Semantics(
                    button: true,
                    label: l10n.truckDetailsClose,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).maybePop(),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: AppColors.chipBackground,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 20,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Icon(
                            Icons.local_shipping,
                            size: 22,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                [
                                  truckTypeLabel(context, result.truckType),
                                  ?capacity,
                                ].join(' • '),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _maskVehicleNumber(result.truckNumber),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'monospace',
                                  letterSpacing: 0.5,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1, color: AppColors.border),
                    const SizedBox(height: 12),
                    _RouteRow(
                      leading: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.green,
                            width: 2.5,
                          ),
                        ),
                      ),
                      text: origin,
                    ),
                    for (final destination in result.destinations) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(7, 2, 0, 2),
                        child: Container(
                          width: 2,
                          height: 14,
                          color: AppColors.textTertiary.withValues(alpha: 0.4),
                        ),
                      ),
                      _RouteRow(
                        leading: const Icon(
                          Icons.location_on,
                          size: 16,
                          color: AppColors.red,
                        ),
                        text: fullLocation(
                          destination.name,
                          destination.city,
                          destination.state,
                          destination.pincode,
                        ),
                      ),
                    ],
                    if (result.length != null || result.height != null) ...[
                      const SizedBox(height: 12),
                      const Divider(height: 1, color: AppColors.border),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          if (result.length != null)
                            _DetailColumn(
                              icon: Icons.straighten,
                              label: l10n.postLengthLabel,
                              value: l10n.feetValue(displayNum(result.length!)),
                            ),
                          if (result.height != null)
                            _DetailColumn(
                              icon: Icons.height,
                              label: l10n.postHeightLabel,
                              value: l10n.feetValue(displayNum(result.height!)),
                            ),
                          if (result.length == null || result.height == null)
                            const Expanded(child: SizedBox.shrink()),
                        ],
                      ),
                    ],
                    if (showMutuals) ...[
                      const SizedBox(height: 12),
                      const Divider(height: 1, color: AppColors.border),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(
                            Icons.people_outline,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            l10n.resultsMutualCount(result.mutualsCount),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () => MutualContactsSheet.show(
                              context,
                              result.userId,
                            ),
                            child: Text(
                              l10n.resultsViewAllMutuals,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (!(FeatureFlags.oneToOneEnabled && isOwnPost)) ...[
                _SheetButton(
                  icon: Icons.videocam,
                  label: l10n.truckDetailsRequestOneToOne,
                  filled: true,
                  onTap: () => _requestOneToOne(context, result),
                ),
                const SizedBox(height: 10),
              ],
              _SheetButton(
                icon: Icons.phone,
                label: l10n.truckDetailsCallDriver,
                filled: false,
                onTap: () => _callNumber(context, result.displayContactNumber),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Origin / destination as one line: name, city, state and pincode, skipping
/// blanks and any part the earlier text already contains ("Delhi" + city
/// "Delhi" is just "Delhi"). The pincode follows the state with a space.
@visibleForTesting
String fullLocation(String name, String? city, String? state, String? pincode) {
  final parts = <String>[];
  for (final raw in [name, city, state]) {
    final part = raw?.trim() ?? '';
    if (part.isEmpty) continue;
    final lower = part.toLowerCase();
    if (parts.any((p) => p.toLowerCase().contains(lower))) continue;
    parts.add(part);
  }
  final text = parts.join(', ');
  final pin = pincode?.trim() ?? '';
  if (pin.isEmpty || text.contains(pin)) return text;
  return text.isEmpty ? pin : '$text $pin';
}

/// Opens the paid 1:1 request form. While FeatureFlags.oneToOneEnabled is off
/// (backend not live yet) the button just says it is coming soon.
void _requestOneToOne(BuildContext context, TruckSearchResultEntity truck) {
  if (FeatureFlags.oneToOneEnabled) {
    RequestOneToOneSheet.show(context, truck);
    return;
  }
  // A dialog, not a snackbar: this runs inside an open bottom sheet, which
  // would cover a snackbar and make the tap look like it did nothing.
  final l10n = AppLocalizations.of(context)!;
  showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      content: Text(l10n.truckDetailsRequestSoon),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: Text(l10n.callClose),
        ),
      ],
    ),
  );
}

class _UserAvatar extends StatelessWidget {
  final String? photoUrl;

  const _UserAvatar({required this.photoUrl});

  @override
  Widget build(BuildContext context) {
    const icon = Icon(Icons.person, size: 28, color: AppColors.primaryBlue);
    final hasPhoto = photoUrl != null && photoUrl!.isNotEmpty;
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryBlue, width: 2),
      ),
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      child: hasPhoto
          ? Image.network(
              photoUrl!,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => icon,
            )
          : icon,
    );
  }
}

class _RouteRow extends StatelessWidget {
  final Widget leading;
  final String text;

  const _RouteRow({required this.leading, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 16, height: 18, child: Center(child: leading)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}

class _SheetButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool filled;
  final VoidCallback onTap;

  const _SheetButton({
    required this.icon,
    required this.label,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final foreground = filled ? AppColors.white : AppColors.textPrimary;
    return Material(
      color: filled ? AppColors.primaryBlue : AppColors.chipBackground,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: SizedBox(
          height: 52,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: filled ? AppColors.white : AppColors.primaryBlueDark,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: foreground,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailColumn extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailColumn({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 13, color: AppColors.textTertiary),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
