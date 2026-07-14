class KycStatusEntity {
  final String status;

  const KycStatusEntity({required this.status});

  bool get isApproved => status == 'approved';
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
