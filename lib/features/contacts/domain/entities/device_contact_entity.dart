class DeviceContactEntity {
  final String name;
  final String rawPhone;
  final String normalizedPhone;
  final String hashedNumber;

  const DeviceContactEntity({
    required this.name,
    required this.rawPhone,
    required this.normalizedPhone,
    required this.hashedNumber,
  });
}
