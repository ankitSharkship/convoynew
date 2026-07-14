import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../shared/widgets/loader.dart';
import '../../../profile/presentation/state/profile_notifier.dart';
import '../state/kyc_notifier.dart';

/// Gates navigation to the Post Truck screen behind KYC approval.
///
/// If the cached profile already shows an approved KYC, navigates straight
/// through. Otherwise it re-checks the live status with the backend (the
/// cache can be stale) before deciding whether to continue to `/post` or
/// divert to the `/kyc` verification flow.
Future<void> navigateToPostTruck(BuildContext context, WidgetRef ref) async {
  final cachedStatus = ref.read(profileNotifierProvider).valueOrNull?.kycStatus;
  if (cachedStatus == 'approved') {
    context.go('/post');
    return;
  }

  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(child: AppLoader()),
  );

  var isApproved = false;
  try {
    final userId = await ref.read(tokenStorageProvider).getUserId();
    if (userId != null) {
      final status = await ref.read(getKycStatusUseCaseProvider).execute(userId);
      isApproved = status.isApproved;
    }
  } catch (_) {
    // Fall through with isApproved = false; the KYC screen will
    // re-verify anyway once the user gets there.
  }

  if (!context.mounted) return;
  context.pop();

  if (isApproved) {
    context.go('/post');
  } else {
    context.go('/kyc');
  }
}
