import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Strips everything but digits, then drops a leading country code so the
/// same real number hashes identically regardless of how it's saved
/// locally (e.g. "+91 98765 43210", "098765 43210", "9876543210" all
/// normalize to the same last-10-digit string).
///
/// This normalization must match whatever the backend uses when hashing
/// the searcher's own registered number, or mutual detection will
/// silently fail. Confirm with backend before relying on this in prod.
String normalizePhoneDigits(String raw) {
  final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
  return digits.length > 10 ? digits.substring(digits.length - 10) : digits;
}

String hashPhone(String normalizedDigits) =>
    sha256.convert(utf8.encode(normalizedDigits)).toString();
