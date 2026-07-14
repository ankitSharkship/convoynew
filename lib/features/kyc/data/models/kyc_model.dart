import '../../domain/entities/kyc_entity.dart';

class KycStatusModel extends KycStatusEntity {
  const KycStatusModel({required super.status});

  factory KycStatusModel.fromJson(Map<String, dynamic> json) {
    final kyc = json['kyc'] as Map<String, dynamic>?;
    final status = kyc != null
        ? (kyc['status'] as String? ?? 'pending')
        : (json['status'] as String? ?? 'pending');
    return KycStatusModel(status: status);
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
    final status =
        user?['kycStatus'] as String? ??
        json['status'] as String? ??
        'approved';
    return VerifyAadhaarOtpResultModel(status: status);
  }
}
