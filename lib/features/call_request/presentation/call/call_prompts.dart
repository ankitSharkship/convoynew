import '../../domain/entities/call_request_entity.dart';

/// Which call screen to bring up on its own.
enum CallPrompt {
  /// The requester's phone is ringing.
  incomingRing,

  /// A call this person is part of is still on (the app was closed or the
  /// connection dropped): offer to get back in.
  rejoin,

  /// The requester has not yet said whether they were satisfied.
  feedback,
}

/// The keys that tell prompts apart (see [CallPromptTarget.key]).
class CallPromptKeys {
  static String ring(String id, DateTime ringEndsAt) =>
      'ring:$id:${ringEndsAt.millisecondsSinceEpoch}';
  static String rejoin(String id) => 'live:$id';
  static String feedback(String id) => 'feedback:$id';
}

class CallPromptTarget {
  final CallPrompt prompt;
  final CallRequestEntity request;

  /// Makes sure each prompt is shown once (a ring per ring, a rejoin per call,
  /// a feedback prompt per request) however often the lists are re-read.
  final String key;

  const CallPromptTarget(this.prompt, this.request, this.key);
}

/// Decides, from what the server says about this person's requests, which
/// screen (if any) to bring up now. A ring beats a rejoin, a rejoin beats the
/// satisfaction question. [handled] holds keys already shown; [onCallScreenFor]
/// is the request whose call screen is already open (never prompt over it).
/// [systemCallScreenFor] holds requests whose phone-level call screen (CallKit)
/// is already up: the app's own ring screen would only double it.
CallPromptTarget? nextCallPrompt({
  required List<CallRequestEntity> outgoing,
  required List<CallRequestEntity> incoming,
  required DateTime now,
  required Set<String> handled,
  String? onCallScreenFor,
  Set<String> systemCallScreenFor = const {},
}) {
  final all = [...outgoing, ...incoming];

  for (final r in outgoing) {
    final ends = r.ringEndsAt;
    if (r.isRequester &&
        r.status == CallStatus.ringing &&
        ends != null &&
        now.isBefore(ends)) {
      final key = CallPromptKeys.ring(r.id, ends);
      if (!handled.contains(key) &&
          onCallScreenFor != r.id &&
          !systemCallScreenFor.contains(r.id)) {
        return CallPromptTarget(CallPrompt.incomingRing, r, key);
      }
    }
  }

  for (final r in all) {
    final inCall =
        r.status == CallStatus.live ||
        // A driver who started a call and lost the app while it rings.
        (r.isProvider && r.status == CallStatus.ringing);
    // On the person's other phone: that phone holds it, this one must not offer to join.
    if (!inCall || r.onAnotherDevice) continue;
    final key = CallPromptKeys.rejoin(r.id);
    if (!handled.contains(key) && onCallScreenFor != r.id) {
      return CallPromptTarget(CallPrompt.rejoin, r, key);
    }
  }

  for (final r in outgoing) {
    final deadline = r.feedbackDeadline;
    if (r.isRequester &&
        r.status == CallStatus.awaitingFeedback &&
        (deadline == null || now.isBefore(deadline))) {
      final key = CallPromptKeys.feedback(r.id);
      if (!handled.contains(key) && onCallScreenFor != r.id) {
        return CallPromptTarget(CallPrompt.feedback, r, key);
      }
    }
  }
  return null;
}
