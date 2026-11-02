import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/reel_entity.dart';
import '../state/my_uploads_notifier.dart';

/// Asks the owner to confirm, then permanently deletes [reel] and refreshes
/// My Uploads. Returns true only if the reel was actually deleted; a failure is
/// reported in a snackbar and leaves everything as it was.
Future<bool> confirmAndDeleteReel(
  BuildContext context,
  WidgetRef ref,
  ReelEntity reel,
) async {
  final l10n = AppLocalizations.of(context)!;
  // Taken up front: the caller may pop its screen once this returns true.
  final messenger = ScaffoldMessenger.of(context);

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l10n.uploadsDeleteConfirmTitle),
      content: Text(l10n.uploadsDeleteConfirmBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(l10n.cancel),
        ),
        TextButton(
          style: TextButton.styleFrom(foregroundColor: AppColors.red),
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(l10n.uploadsMenuDelete),
        ),
      ],
    ),
  );
  if (confirmed != true) return false;

  try {
    await ref.read(deleteReelUseCaseProvider).execute(reel.id);
  } catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(ApiException.messageFor(e))));
    return false;
  }
  ref.invalidate(myUploadsProvider);
  messenger.showSnackBar(SnackBar(content: Text(l10n.uploadsDeleteSuccess)));
  return true;
}
