import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../auth/presentation/state/auth_notifier.dart';
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
          child: Text(
            AppLocalizations.of(context)!.appName,
            style: const TextStyle(
              color: AppColors.primaryBlue,
              fontSize: 44,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
        ),
      ),
    );
  }
}
