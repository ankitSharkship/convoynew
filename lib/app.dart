import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/l10n/locale_notifier.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/feature_flags.dart';
import 'features/call_request/incoming_call/incoming_call_controller.dart';
import 'features/call_request/presentation/call/call_coordinator.dart';
import 'features/call_request/presentation/state/call_request_notifier.dart';
import 'features/devices/presentation/state/device_notifier.dart';
import 'l10n/generated/app_localizations.dart';
import 'shared/widgets/offline_banner.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final locale = ref.watch(localeNotifierProvider);
    // Keeps listening for FCM token rotation for the app's entire lifetime,
    // regardless of which route is active.
    ref.watch(deviceTokenRefreshListenerProvider);
    // Pushes about 1:1 calls: keeps what's on screen fresh, and a tapped "new
    // request" push asks for that request to be opened.
    ref.watch(callPushListenerProvider);
    // The phone's own incoming-call screen (CallKit / full-screen call).
    if (FeatureFlags.oneToOneEnabled) ref.watch(incomingCallControllerProvider);
    ref.listen(pendingReviewRequestProvider, (_, requested) {
      // The review sheet lives on Home: if the app is already running, bring
      // Home forward. (From a cold start the app is still on splash/login; it
      // reaches Home by itself and the banner opens the request then.)
      if (requested != null &&
          isPastLaunchAndLogin(router.routeInformationProvider.value.uri.path)) {
        router.go('/home');
      }
    });
    return MaterialApp.router(
      title: 'Bounut',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
      locale: locale,
      supportedLocales: supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,

      ],
      // Global "no internet connection" strip, sits above every route
      // (auth, kyc, the tabbed shell, etc.) rather than living inside any
      // one screen — see OfflineBanner for why this isn't a Snackbar.
      builder: (context, child) {
        final app = Column(
          children: [
            const OfflineBanner(),
            Expanded(child: child ?? const SizedBox.shrink()),
          ],
        );
        // With 1:1 calls on, the ring / "still in a call" / "were you
        // satisfied?" screens come up on their own, wherever the person is.
        return FeatureFlags.oneToOneEnabled
            ? CallCoordinator(router: router, child: app)
            : app;
      },
    );
  }
}
