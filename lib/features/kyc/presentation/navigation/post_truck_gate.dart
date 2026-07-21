import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../shared/widgets/loader.dart';
import '../../domain/entities/kyc_entity.dart';
import '../state/kyc_notifier.dart';

/// Fetches the user's live KYC status, showing a blocking loader while it
/// does. Never trusts the cached [ProfileEntity] for this — a cached
/// profile is returned synchronously (and possibly stale, e.g. missing a
/// field added after it was cached, or reflecting a status that's since
/// changed server-side) before any background refresh completes, which is
/// exactly the gap that let an unapproved user through once already.
/// Returns null if the check fails outright (network error) — callers
/// should treat that the same as "not verified".
Future<KycStatusEntity?> _fetchLiveKycStatus(
  BuildContext context,
  WidgetRef ref,
) async {
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(child: AppLoader()),
  );

  KycStatusEntity? status;
  try {
    final userId = await ref.read(tokenStorageProvider).getUserId();
    if (userId != null) {
      status = await ref.read(getKycStatusUseCaseProvider).execute(userId);
    }
  } catch (_) {
    // Fall through with status = null; the KYC screen will re-verify
    // anyway once the user gets there.
  }

  if (context.mounted) context.pop();
  return status;
}

/// Gates navigation to the Post Truck screen behind KYC approval.
///
/// Routes to `/post` if fully approved, straight to `/face_capture` if
/// Aadhaar is already done and only the photo step remains (skipping
/// Aadhaar entry entirely — resending an OTP there resets progress back to
/// step 1), or `/kyc` to start from scratch.
Future<void> navigateToPostTruck(BuildContext context, WidgetRef ref) async {
  final status = await _fetchLiveKycStatus(context, ref);
  if (!context.mounted) return;

  if (status?.isApproved ?? false) {
    context.push('/post');
  } else if (status?.isPhotoStepPending ?? false) {
    context.push('/face_capture', extra: '/post');
  } else {
    context.push('/kyc');
  }
}

/// Same live-verified routing as [navigateToPostTruck], for the Profile
/// screen's "KYC" row — which has no `/post` destination to continue to,
/// so it calls [onAlreadyVerified] instead of navigating when the user
/// turns out to already be fully approved.
Future<void> navigateToKycVerification(
  BuildContext context,
  WidgetRef ref, {
  required VoidCallback onAlreadyVerified,
}) async {
  final status = await _fetchLiveKycStatus(context, ref);
  if (!context.mounted) return;

  if (status?.isApproved ?? false) {
    onAlreadyVerified();
  } else if (status?.isPhotoStepPending ?? false) {
    context.push('/face_capture');
  } else {
    context.push('/kyc');
  }
}
