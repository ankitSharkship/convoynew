import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/call_request_entity.dart';
import 'call_formatting.dart';
import 'call_routes.dart';
import 'call_screen_registry.dart';
import 'call_session_controller.dart';

/// "You're still in a call": shown when the app opens (or comes back) and the
/// server says a call this person is part of is still on. Rejoin carries on;
/// End call tells the server it is over.
class RejoinScreen extends ConsumerStatefulWidget {
  final CallRequestEntity request;

  const RejoinScreen({super.key, required this.request});

  @override
  ConsumerState<RejoinScreen> createState() => _RejoinScreenState();
}

class _RejoinScreenState extends ConsumerState<RejoinScreen> {
  bool _busy = false;
  late final CallScreenRegistry _registry;

  @override
  void initState() {
    super.initState();
    _registry = ref.read(callScreenRegistryProvider)
      ..enter(widget.request.id, live: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(callSessionProvider(widget.request.id).notifier).rejoinOffered();
    });
  }

  @override
  void dispose() {
    _registry.leave(widget.request.id, live: false);
    super.dispose();
  }

  void _leave() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  void _rejoin() {
    // The call is already open on this phone (this prompt should not have come
    // up): don't start a second call screen on top of it, just go back to it.
    if (_registry.liveOpen(widget.request.id)) {
      _leave();
      return;
    }
    context.pushReplacement(
      CallRoutes.call(
        widget.request.id,
        mode: 'rejoin',
        driver: widget.request.isProvider,
      ),
    );
  }

  Future<void> _end() async {
    setState(() => _busy = true);
    await ref
        .read(callSessionProvider(widget.request.id).notifier)
        .endWithoutRejoining();
    if (mounted) _leave();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Keeps the session alive while this prompt is up.
    ref.watch(callSessionProvider(widget.request.id));
    final name = partyName(
      widget.request.otherParty,
      l10n.oneToOneRequesterFallback,
    );

    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.phone_in_talk, color: AppColors.white, size: 52),
              const SizedBox(height: 16),
              Text(
                l10n.callRejoinTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.callRejoinBody(name),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.white.withValues(alpha: 0.8),
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: _busy ? null : _rejoin,
                child: Text(l10n.callRejoinButton),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: _busy ? null : _end,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.white,
                  side: const BorderSide(color: AppColors.white),
                ),
                child: Text(l10n.callRejoinEndButton),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
