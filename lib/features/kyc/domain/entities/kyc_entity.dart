class KycStatusEntity {
  final String status;

  /// "aadhaar" (not started/needs Aadhaar OTP), "photo" (Aadhaar done,
  /// selfie pending), or "completed". Null for accounts predating the
  /// two-step flow.
  final String? step;

  const KycStatusEntity({required this.status, this.step});

  bool get isApproved => status == 'approved';

  /// Aadhaar step is done and only the selfie/photo step remains.
  bool get isPhotoStepPending => step == 'photo';
}

class SendAadhaarOtpResultEntity {
  final String refId;
  final String message;

  const SendAadhaarOtpResultEntity({
    required this.refId,
    required this.message,
  });
}

class VerifyAadhaarOtpResultEntity {
  final String status;

  const VerifyAadhaarOtpResultEntity({required this.status});

  bool get isApproved => status == 'approved';
}

/// Result of a pure, side-effect-free `/aadhaar/check` lookup — purely a UX
/// convenience for live-typing feedback. `send-otp` enforces the identical
/// check regardless, so this result is never the actual source of truth.
class AadhaarAvailabilityEntity {
  final bool available;
  final String? message;

  const AadhaarAvailabilityEntity({required this.available, this.message});
}
