import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/call_request_repository.dart';
import '../../media/agora_call_media_engine.dart';
import '../../media/call_media_engine.dart';
import '../../media/call_permissions.dart';
import 'call_request_notifier.dart';

// Plain (hand-written) providers rather than generated ones: they are the seams
// the tests replace (the repository, the media engine, permissions and the
// clock) for the call screens.

final callRepositoryProvider = Provider<CallRequestRepository>(
  (ref) => ref.watch(callRequestRepositoryProvider),
);

final callMediaEngineFactoryProvider = Provider<CallMediaEngine Function()>(
  (ref) => AgoraCallMediaEngine.new,
);

final callPermissionsProvider = Provider<CallPermissions>(
  (ref) => const DeviceCallPermissions(),
);

final callClockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// The call prompts (ring, rejoin, "were you satisfied?") already shown in this
/// run of the app, so none comes up twice. Shared by the coordinator that
/// brings prompts up and the screens that deal with them ("Decide later" must
/// not be answered by the same question popping straight back up).
final handledCallPromptsProvider = Provider<Set<String>>((ref) => <String>{});
