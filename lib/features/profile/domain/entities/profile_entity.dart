class ProfileEntity {
  final String id;
  final String name;
  final String phone;
  final String memberSince;
  final double rating;
  final int totalPosts;
  final int callsMade;
  final int responseRate;
  final String kycStatus;

  /// "aadhaar", "photo", or "completed" — which step of the two-step KYC
  /// flow the user is on. Null for accounts predating that flow.
  final String? kycStep;
  final String accountStatus;
  final String? photoPath;
  final String? profilePhotoUrl;

  const ProfileEntity({
    required this.id,
    required this.name,
    required this.phone,
    required this.memberSince,
    required this.rating,
    required this.totalPosts,
    required this.callsMade,
    required this.responseRate,
    required this.kycStatus,
    this.kycStep,
    this.accountStatus = 'active',
    this.photoPath,
    this.profilePhotoUrl,
  });

  ProfileEntity copyWith({
    String? id,
    String? name,
    String? phone,
    String? memberSince,
    double? rating,
    int? totalPosts,
    int? callsMade,
    int? responseRate,
    String? kycStatus,
    String? kycStep,
    String? accountStatus,
    String? photoPath,
    String? profilePhotoUrl,
  }) {
    return ProfileEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      memberSince: memberSince ?? this.memberSince,
      rating: rating ?? this.rating,
      totalPosts: totalPosts ?? this.totalPosts,
      callsMade: callsMade ?? this.callsMade,
      responseRate: responseRate ?? this.responseRate,
      kycStatus: kycStatus ?? this.kycStatus,
      kycStep: kycStep ?? this.kycStep,
      accountStatus: accountStatus ?? this.accountStatus,
      photoPath: photoPath ?? this.photoPath,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
    );
  }
}
