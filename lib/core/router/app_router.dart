import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/presentation/screens/otp_screen.dart';
import '../../features/auth/presentation/screens/phone_screen.dart';
import '../../features/call/presentation/screens/call_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/post/presentation/screens/post_form_screen.dart';
import '../../features/post/presentation/screens/post_success_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/search/presentation/screens/search_results_screen.dart';
import '../../features/search/presentation/screens/search_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../shared/widgets/main_shell.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(
        path: '/onboarding',
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(path: '/auth/phone', builder: (_, __) => const PhoneScreen()),
      GoRoute(
        path: '/auth/otp',
        builder: (context, state) {
          final phone = state.uri.queryParameters['phone'] ?? '';
          return OtpScreen(phone: phone);
        },
      ),
      GoRoute(
        path: '/call',
        builder: (context, state) {
          final name = state.uri.queryParameters['name'] ?? '';
          final phone = state.uri.queryParameters['phone'] ?? '';
          final initials = state.uri.queryParameters['initials'] ?? '';
          return CallScreen(driverName: name, phone: phone, initials: initials);
        },
      ),
      GoRoute(
        path: '/post',
        builder: (_, __) => const PostFormScreen(),
        routes: [
          GoRoute(
            path: 'success',
            builder: (context, state) {
              final extra = state.extra as Map<String, String>? ?? {};
              return PostSuccessScreen(
                truckType: extra['truckType'] ?? 'Open Body',
                capacity: extra['capacity'] ?? '9 Ton',
                origin: extra['origin'] ?? 'Bhiwandi, MH',
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: '/search/results',
        builder: (_, __) => const SearchResultsScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/search',
                builder: (_, __) => const SearchScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (_, __) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

final sharedPreferencesProvider = Provider<SharedPreferences>(
  (_) => throw UnimplementedError('Override sharedPreferencesProvider in main'),
);
