class MutualContactEntity {
  final String name;
  final String hashedNumber;
  final String? phoneNumber;

  const MutualContactEntity({
    required this.name,
    required this.hashedNumber,
    this.phoneNumber,
  });

  MutualContactEntity copyWith({String? phoneNumber}) => MutualContactEntity(
    name: name,
    hashedNumber: hashedNumber,
    phoneNumber: phoneNumber ?? this.phoneNumber,
  );
}
