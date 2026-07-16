import '../../domain/entities/mutual_contact_entity.dart';

MutualContactEntity mutualContactFromJson(Map<String, dynamic> json) =>
    MutualContactEntity(
      name: json['name'] as String? ?? '',
      hashedNumber: json['hashedNumber'] as String? ?? '',
    );

List<MutualContactEntity> mutualContactsFromJson(Map<String, dynamic> json) {
  final list = json['mutualContacts'] as List<dynamic>? ?? [];
  return list
      .map((e) => mutualContactFromJson(e as Map<String, dynamic>))
      .toList();
}
