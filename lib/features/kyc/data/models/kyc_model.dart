import '../../domain/entities/kyc_entity.dart';

class KycStatusModel extends KycStatusEntity {
  const KycStatusModel({required super.status, super.step});

  factory KycStatusModel.fromJson(Map<String, dynamic> json) {
    // The overall two-step status/step always live at the top level. Any
    // nested "kyc" object is just the raw Aadhaar sub-record (has its own
    // unrelated `status`, e.g. "approved" meaning the Aadhaar check itself
    // succeeded, and has no `kycStep` at all) — never read status/step
    // from it, or a user who's only done Aadhaar reads as fully approved.
    final status = json['status'] as String? ?? 'pending';
    final step = json['kycStep'] as String?;
    return KycStatusModel(status: status, step: step);
  }
}

class SendAadhaarOtpResultModel extends SendAadhaarOtpResultEntity {
  const SendAadhaarOtpResultModel({
    required super.refId,
    required super.message,
  });

  factory SendAadhaarOtpResultModel.fromJson(Map<String, dynamic> json) {
    return SendAadhaarOtpResultModel(
      refId: json['refId'] as String,
      message: json['message'] as String? ?? 'OTP sent',
    );
  }
}

class VerifyAadhaarOtpResultModel extends VerifyAadhaarOtpResultEntity {
  const VerifyAadhaarOtpResultModel({required super.status});

  factory VerifyAadhaarOtpResultModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    // Aadhaar verification is only step 1 of 2 — never default to
    // 'approved' here. Full approval is confirmed separately via
    // GET /api/kyc/status after the photo step (see FaceReviewScreen).
    final status =
        user?['kycStatus'] as String? ??
        json['status'] as String? ??
        'in_progress';
    return VerifyAadhaarOtpResultModel(status: status);
  }
}

class AadhaarAvailabilityModel extends AadhaarAvailabilityEntity {
  const AadhaarAvailabilityModel({required super.available, super.message});

  factory AadhaarAvailabilityModel.fromJson(Map<String, dynamic> json) {
    return AadhaarAvailabilityModel(
      available: json['available'] as bool? ?? true,
      message: json['message'] as String?,
    );
  }
}
