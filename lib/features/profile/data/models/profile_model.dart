class ProfileModel {
  final String id;
  final String mobile;
  final String name;
  final String? profilePhotoUrl;
  final String kycStatus;
  final String accountStatus;
  final DateTime? createdDate;

  const ProfileModel({
    required this.id,
    required this.mobile,
    required this.name,
    this.profilePhotoUrl,
    required this.kycStatus,
    required this.accountStatus,
    this.createdDate,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
        id: json['_id'] as String? ?? '',
        mobile: json['mobile'] as String? ?? '',
        name: json['name'] as String? ?? '',
        profilePhotoUrl: json['profilePhoto'] as String?,
        kycStatus: json['kycStatus'] as String? ?? 'not_started',
        accountStatus: json['accountStatus'] as String? ?? 'active',
        createdDate: json['createdDate'] != null
            ? DateTime.tryParse(json['createdDate'] as String)
            : null,
      );

  factory ProfileModel.fromCacheJson(Map<String, dynamic> json) =>
      ProfileModel(
        id: json['id'] as String? ?? '',
        mobile: json['mobile'] as String? ?? '',
        name: json['name'] as String? ?? '',
        profilePhotoUrl: json['profilePhotoUrl'] as String?,
        kycStatus: json['kycStatus'] as String? ?? 'not_started',
        accountStatus: json['accountStatus'] as String? ?? 'active',
        createdDate: json['createdDate'] != null
            ? DateTime.tryParse(json['createdDate'] as String)
            : null,
      );

  Map<String, dynamic> toCacheJson() => {
        'id': id,
        'mobile': mobile,
        'name': name,
        'profilePhotoUrl': profilePhotoUrl,
        'kycStatus': kycStatus,
        'accountStatus': accountStatus,
        'createdDate': createdDate?.toIso8601String(),
      };
}
