import '../../../../core/network/api_exception.dart';

/// Thrown specifically when `POST /kyc/aadhaar/verify/{user_id}` returns
/// 409 — the OTP itself was valid, but this Aadhaar collided with another
/// account's verification at the final commit (the race-safety net behind
/// the partial unique index on `aadhaar_hash`). Retrying the same OTP or
/// even the same Aadhaar will never succeed, so callers must treat this
/// differently from an ordinary verify failure (e.g. a wrong OTP, where
/// staying on the OTP screen to retry makes sense).
///
/// Extends [ApiException] so any caller that only cares about a
/// user-facing message (via [ApiException.messageFor]) keeps working
/// unchanged; only code that needs to react specially checks `is
/// AadhaarConflictException`.
class AadhaarConflictException extends ApiException {
  const AadhaarConflictException(super.message);
}
