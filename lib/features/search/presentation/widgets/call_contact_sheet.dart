import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/truck_search_result_entity.dart';

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

/// Bottom sheet letting the user choose who to call when a search result
/// has a separate designated contact from whoever posted it — showing both
/// numbers side by side rather than silently dialing just one of them.
/// Only meaningful when [TruckSearchResultEntity.hasAlternateContact] is
/// true; callers should dial directly otherwise.
class CallContactSheet extends StatelessWidget {
  final TruckSearchResultEntity result;

  const CallContactSheet({super.key, required this.result});

  static Future<void> show(
    BuildContext context,
    TruckSearchResultEntity result,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CallContactSheet(result: result),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
              Text(
                l10n.resultsCallSheetTitle,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              _CallOptionTile(
                label: l10n.resultsContactLabel,
                name: result.contactName ?? '',
                phone: result.contactNumber ?? '',
              ),
              const Divider(height: 1, color: Color(0xFFF0F4F8)),
              _CallOptionTile(
                label: l10n.resultsPostedByLabel,
                name: result.userName,
                phone: result.userMobile,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CallOptionTile extends StatelessWidget {
  final String label;
  final String name;
  final String phone;

  const _CallOptionTile({
    required this.label,
    required this.name,
    required this.phone,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _callNumber(context, phone),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.phone,
                size: 18,
                color: AppColors.primaryBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
