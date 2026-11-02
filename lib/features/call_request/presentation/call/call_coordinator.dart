import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../domain/entities/call_request_entity.dart';
import '../../incoming_call/incoming_call_controller.dart';
import '../state/call_providers.dart';
import '../state/outgoing_requests_notifier.dart';
import 'call_prompts.dart';
import 'call_screen_registry.dart';
import 'call_routes.dart';

/// Brings up the right call screen on its own, wherever the person is in the
/// app: the ring when the driver calls, "you are still in a call" after the app
/// was closed mid-call, and the satisfaction question that is still owed.
///
/// It looks at the server once the person is past login and each time the app
/// comes back to the front, then keeps watching the requester's own open
/// requests (refreshed faster while a ring is likely, and at once on a push).
/// Each prompt is shown once per app run; [nextCallPrompt] holds the rules.
class CallCoordinator extends ConsumerStatefulWidget {
  final GoRouter router;
  final Widget child;

  const CallCoordinator({super.key, required this.router, required this.child});

  @override
  ConsumerState<CallCoordinator> createState() => _CallCoordinatorState();
}

class _CallCoordinatorState extends ConsumerState<CallCoordinator>
    with WidgetsBindingObserver {
  List<CallRequestEntity> _incoming = const [];
  bool _started = false;
  bool _checking = false;
  ProviderSubscription<AsyncValue<List<CallRequestEntity>>>? _outgoingSub;
  ProviderSubscription<String?>? _answeredSub;
  late final CallScreenRegistry _screens;

  String get _path => widget.router.routeInformationProvider.value.uri.path;

  @override
  void initState() {
    super.initState();
    _screens = ref.read(callScreenRegistryProvider);
    _screens.addListener(_onScreensChanged);
    WidgetsBinding.instance.addObserver(this);
    widget.router.routerDelegate.addListener(_onRoute);
    WidgetsBinding.instance.addPostFrameCallback((_) => _onRoute());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _screens.removeListener(_onScreensChanged);
    widget.router.routerDelegate.removeListener(_onRoute);
    _outgoingSub?.close();
    _answeredSub?.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _started) _check();
  }

  /// A call screen closed: whatever was waiting for it (a ring, a question) can
  /// come up now. In a microtask, so nothing is pushed while the screen is still
  /// being taken down (the closing screen calls this from its dispose), yet it
  /// does not wait for a next frame that an idle app may never draw.
  void _onScreensChanged() {
    Future<void>.microtask(() {
      if (mounted && _started) _evaluate();
    });
  }

  void _onRoute() {
    if (!mounted) return;
    if (!_started) {
      if (!isPastLaunchAndLogin(_path)) return;
      _started = true;
      // Only from here on does anything go to the server: before login there is
      // nothing to ask about.
      _outgoingSub = ref.listenManual(
        outgoingActiveRequestsProvider,
        (_, _) => _evaluate(),
      );
      // A call answered from the phone's own call screen (possibly the very
      // reason the app was just opened) goes straight to the call.
      _answeredSub = ref.listenManual(
        pendingAnsweredCallProvider,
        (_, _) => _openAnsweredCall(),
      );
      _openAnsweredCall();
      unawaited(ref.read(incomingCallControllerProvider.notifier).askPermissionsOnce());
      _check(firstLook: true);
    } else {
      // A call screen was just closed (or opened): see whether anything is owed.
      _evaluate();
    }
  }

  /// Looks at the server: the requester's own open requests and (as the
  /// driver) what is still on. [firstLook] is the very first time, when
  /// listening to the provider has just started the read: no second one.
  void _openAnsweredCall() {
    if (!mounted) return;
    final id = ref.read(pendingAnsweredCallProvider);
    if (id == null || !isPastLaunchAndLogin(_path)) return;
    ref.read(pendingAnsweredCallProvider.notifier).state = null;
    if (_screens.liveOpen(id)) return; // already on that call
    widget.router.push(CallRoutes.call(id, mode: 'answer', driver: false));
  }

  Future<void> _check({bool firstLook = false}) async {
    if (_checking) return;
    _checking = true;
    try {
      await Future.wait([
        (firstLook
                ? ref.read(outgoingActiveRequestsProvider.future)
                : ref.read(outgoingActiveRequestsProvider.notifier).refresh())
            .then<void>((_) {})
            .catchError((_) {}),
        ref
            .read(callRepositoryProvider)
            .getIncoming()
            .then((list) => _incoming = list)
            .catchError((_) => _incoming = const <CallRequestEntity>[]),
      ]);
    } finally {
      _checking = false;
    }
    if (!mounted) return;
    _evaluate();
    // The driver-side list was a one-time look: don't act on it again later.
    _incoming = const [];
  }

  void _evaluate() {
    if (!mounted || !isPastLaunchAndLogin(_path)) return;
    // Never open one call screen over another. (Asked of the registry, not the
    // router: the router's location does not change when a screen is pushed.)
    if (_screens.anyOpen) return;

    final handled = ref.read(handledCallPromptsProvider);
    final target = nextCallPrompt(
      outgoing: ref.read(outgoingActiveRequestsProvider).valueOrNull ?? const [],
      incoming: _incoming,
      now: ref.read(callClockProvider)(),
      handled: handled,
      systemCallScreenFor: ref.read(callKitShownProvider),
    );
    if (target == null) return;
    handled.add(target.key);

    final id = target.request.id;
    switch (target.prompt) {
      case CallPrompt.incomingRing:
        widget.router.push(CallRoutes.incoming(id), extra: target.request);
      case CallPrompt.rejoin:
        widget.router.push(CallRoutes.rejoin(id), extra: target.request);
      case CallPrompt.feedback:
        widget.router.push(CallRoutes.feedback(id), extra: target.request);
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
