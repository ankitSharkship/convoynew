import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/entities/call_request_entity.dart';
import '../state/call_request_notifier.dart';

/// Gives [builder] the request: the one a route was opened with ([initial]),
/// or, when there is none (the screen was opened from a link or restored),
/// the one loaded from the server.
class CallRequestLoader extends ConsumerWidget {
  final String requestId;
  final CallRequestEntity? initial;
  final Widget Function(CallRequestEntity request) builder;

  const CallRequestLoader({
    super.key,
    required this.requestId,
    required this.initial,
    required this.builder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final given = initial;
    if (given != null) return builder(given);
    return ref
        .watch(callRequestNotifierProvider(requestId))
        .when(
          data: builder,
          loading: () => const Scaffold(
            backgroundColor: AppColors.primaryDark,
            body: Center(child: CircularProgressIndicator()),
          ),
          error: (error, _) => Scaffold(
            backgroundColor: AppColors.primaryDark,
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  ApiException.messageFor(error),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.white),
                ),
              ),
            ),
          ),
        );
  }
}
