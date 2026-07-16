import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/mutual_contact_entity.dart';
import '../state/mutual_contacts_notifier.dart';

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

/// Bottom sheet listing the mutual contacts between the logged-in user and
/// another user's post. Names come straight from the server; phone numbers
/// are resolved on-device from the searcher's own synced contact cache,
/// since the server only ever stores/returns a one-way hash.
class MutualContactsSheet extends ConsumerWidget {
  final String otherUserId;

  const MutualContactsSheet({super.key, required this.otherUserId});

  static Future<void> show(BuildContext context, String otherUserId) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MutualContactsSheet(otherUserId: otherUserId),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final mutualsAsync = ref.watch(
      mutualContactsProvider(otherUserId: otherUserId),
    );

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
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
                l10n.mutualContactsSheetTitle,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: mutualsAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (e, _) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: Text(
                        ApiException.messageFor(e),
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.red,
                        ),
                      ),
                    ),
                  ),
                  data: (contacts) => contacts.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: Center(
                            child: Text(
                              l10n.mutualContactsEmpty,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          itemCount: contacts.length,
                          separatorBuilder: (_, _) => const Divider(
                            height: 1,
                            color: Color(0xFFF0F4F8),
                          ),
                          itemBuilder: (context, i) =>
                              _MutualContactTile(contact: contacts[i]),
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

class _MutualContactTile extends StatelessWidget {
  final MutualContactEntity contact;

  const _MutualContactTile({required this.contact});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final phone = contact.phoneNumber;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  phone ?? l10n.mutualContactsNumberUnavailable,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (phone != null)
            GestureDetector(
              onTap: () => _callNumber(context, phone),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.phone,
                  size: 16,
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
