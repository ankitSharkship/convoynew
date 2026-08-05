import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/dio_client.dart';
import '../../../auth/presentation/state/auth_notifier.dart';
import '../../../contacts/presentation/state/contacts_sync_notifier.dart';
import '../../../devices/presentation/state/device_notifier.dart';
import '../../../onboarding/presentation/state/onboarding_notifier.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;

    final onboardingSeen = await ref
        .read(checkOnboardingSeenUseCaseProvider)
        .execute();

    if (!onboardingSeen) {
      if (mounted) context.go('/onboarding');
      return;
    }

    final session = await ref.read(authRepositoryProvider).getSession();

    if (!mounted) return;
    if (session != null) {
      // Fire-and-forget: re-checks/re-requests contacts permission (and
      // syncs if stale) once per cold app open, without blocking
      // navigation on it. Deliberately not tied to app-lifecycle resume
      // events — that caused a permission-dialog feedback loop before.
      ref.read(contactsSyncNotifierProvider.notifier).syncIfStale();
      // Same fire-and-forget treatment: only actually calls the register
      // endpoint if the FCM token has changed since the last time this
      // device synced (see SyncDeviceTokenIfChangedUseCase) — a login
      // itself already registers unconditionally, so this only matters
      // for a session resumed on a fresh cold start. Provider reads are
      // captured now, before navigating away, since `ref` itself becomes
      // unusable once this screen is disposed.
      final tokenStorage = ref.read(tokenStorageProvider);
      final syncUseCase = ref.read(syncDeviceTokenIfChangedUseCaseProvider);
      unawaited(
        tokenStorage
            .getUserId()
            .then((userId) {
              if (userId == null) return null;
              return syncUseCase.execute(userId);
            })
            .catchError((_) {}),
      );
      context.go('/home');
    } else {
      context.go('/auth/phone');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: Center(
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/app_logo.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
