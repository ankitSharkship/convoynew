import 'dart:io';

import 'package:convoynew/features/kyc/presentation/screens/face_capture_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/presentation/screens/enter_name_screen.dart';
import '../../features/auth/presentation/screens/otp_screen.dart';
import '../../features/auth/presentation/screens/phone_screen.dart';
import '../../features/call/presentation/screens/call_screen.dart';
import '../../features/heatmap/presentation/screens/heatmap_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/home/presentation/screens/manage_history_screen.dart';
import '../../features/kyc/presentation/screens/face_review_screen.dart';
import '../../features/kyc/presentation/screens/kyc_otp_screen.dart';
import '../../features/kyc/presentation/screens/kyc_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/post/domain/entities/trip_entity.dart';
import '../../features/post/presentation/screens/my_trips_screen.dart';
import '../../features/post/presentation/screens/my_trucks_screen.dart';
import '../../features/post/presentation/screens/post_form_screen.dart';
import '../../features/post/presentation/screens/post_success_screen.dart';
import '../constants/feature_flags.dart';
import '../../features/scratch_cards/domain/entities/scratch_card_entity.dart';
import '../../features/scratch_cards/presentation/screens/post_scratch_card_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/reels/presentation/screens/my_uploads_screen.dart';
import '../../features/reels/presentation/screens/reel_details_screen.dart';
import '../../features/reels/presentation/screens/reel_record_screen.dart';
import '../../features/reels/presentation/screens/reel_trim_screen.dart';
import '../../features/reels/presentation/screens/reel_upload_success_screen.dart';
import '../../features/reels/presentation/screens/reels_screen.dart';
import '../../features/search/presentation/screens/search_results_screen.dart';
import '../../features/search/presentation/screens/search_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/truck_map/presentation/screens/truck_map_screen.dart';
import '../../features/wallet/presentation/screens/wallet_screen.dart';
import '../../shared/widgets/main_shell.dart';
import '../network/dio_client.dart';

part 'app_router.g.dart';

const _publicPaths = {'/splash', '/onboarding', '/auth/phone', '/auth/otp'};

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  final tokenStorage = ref.watch(tokenStorageProvider);
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: authRevocationNotifier,
    redirect: (context, state) async {
      if (_publicPaths.contains(state.matchedLocation)) return null;
      final token = await tokenStorage.getAccessToken();
      if (token == null) return '/auth/phone';
      return null;
    },
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
        path: '/auth/enter-name',
        builder: (_, __) => const EnterNameScreen(),
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
              final extra = state.extra as Map<String, dynamic>? ?? {};
              return PostSuccessScreen(
                truckType: extra['truckType'] as String? ?? 'Open Body',
                capacity: extra['capacity'] as int? ?? 9,
                origin: extra['origin'] as String? ?? 'Bhiwandi, MH',
              );
            },
          ),
          GoRoute(
            path: 'edit',
            builder: (context, state) {
              final trip = state.extra as TripEntity?;
              return PostFormScreen(editingTrip: trip);
            },
          ),
          if (FeatureFlags.scratchCardsEnabled)
            GoRoute(
              path: 'scratch-card',
              builder: (context, state) {
                final extra = state.extra as Map<String, dynamic>? ?? {};
                return PostScratchCardScreen(
                  truckType: extra['truckType'] as String? ?? 'Open Body',
                  capacity: extra['capacity'] as int? ?? 9,
                  origin: extra['origin'] as String? ?? 'Bhiwandi, MH',
                  scratchCard: extra['scratchCard'] as ScratchCardEntity,
                );
              },
            ),
        ],
      ),
      GoRoute(
        path: '/search/results',
        builder: (_, __) => const SearchResultsScreen(),
      ),
      GoRoute(
        path: '/truck-map',
        builder: (_, __) => const TruckMapScreen(),
      ),
      GoRoute(
        path: '/profile/vehicles',
        builder: (_, __) => const MyTrucksScreen(),
      ),
      GoRoute(
        path: '/face_capture',
        // `extra` is an optional route to continue to once the captured
        // photo is confirmed (e.g. the KYC flow continues on to `/post`);
        // left null for callers (like the profile screen's test button)
        // that just want the default "update photo, go back to /profile".
        builder: (context, state) {
          final nextRoute = state.extra as String?;
          return FaceCaptureScreen(
            onCaptured: (file) => context.pushReplacement(
              '/face_review',
              extra: (imageFile: file, nextRoute: nextRoute),
            ),
          );
        },
      ),
      GoRoute(
        path: '/face_review',
        builder: (context, state) {
          final args = state.extra as ({File imageFile, String? nextRoute});
          return FaceReviewScreen(
            imageFile: args.imageFile,
            nextRoute: args.nextRoute,
          );
        },
      ),
      GoRoute(
        path: '/profile/trips',
        builder: (_, __) => const MyTripsScreen(),
      ),
      GoRoute(
        path: '/profile/uploads',
        builder: (_, __) => const MyUploadsScreen(),
      ),
      GoRoute(
        path: '/reels/create/record',
        builder: (_, __) => const ReelRecordScreen(),
      ),
      GoRoute(
        path: '/reels/create/trim',
        builder: (context, state) =>
            ReelTrimScreen(videoPath: state.extra as String),
      ),
      GoRoute(
        path: '/reels/create/details',
        builder: (context, state) =>
            ReelDetailsScreen(videoPath: state.extra as String),
      ),
      GoRoute(
        path: '/reels/create/success',
        builder: (_, __) => const ReelUploadSuccessScreen(),
      ),
      GoRoute(
        path: '/home/manage',
        builder: (_, __) => const ManageHistoryScreen(),
      ),
      GoRoute(
        path: '/kyc',
        builder: (_, __) => const KycScreen(),
        routes: [
          GoRoute(path: 'otp', builder: (_, __) => const KycOtpScreen()),
        ],
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
              GoRoute(path: '/reels', builder: (_, __) => const ReelsScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/heatmap',
                builder: (_, __) => const HeatmapScreen(),
              ),
            ],
          ),
          if (FeatureFlags.walletEnabled)
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/wallet',
                  builder: (_, __) => const WalletScreen(),
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
