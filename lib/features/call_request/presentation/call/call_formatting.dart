import '../../domain/entities/call_request_entity.dart';

/// "12:05" for 725 seconds, "1:02:03" past an hour.
String formatClock(int totalSeconds) {
  final s = totalSeconds < 0 ? 0 : totalSeconds;
  final h = s ~/ 3600;
  final m = (s % 3600) ~/ 60;
  final sec = (s % 60).toString().padLeft(2, '0');
  return h > 0
      ? '$h:${m.toString().padLeft(2, '0')}:$sec'
      : '${m.toString().padLeft(2, '0')}:$sec';
}

/// "2 min 5 s" style length for the "you were on the call for ..." line.
String formatSpoken(int totalSeconds) {
  final s = totalSeconds < 0 ? 0 : totalSeconds;
  final m = s ~/ 60;
  final sec = s % 60;
  if (m == 0) return '$sec s';
  if (sec == 0) return '$m min';
  return '$m min $sec s';
}

/// The other person's name, or [fallback] when they have none.
String partyName(CallPartyEntity party, String fallback) {
  final name = (party.name ?? '').trim();
  return name.isEmpty ? fallback : name;
}
