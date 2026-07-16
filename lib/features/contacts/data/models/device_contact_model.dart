import 'package:flutter_contacts/flutter_contacts.dart';

import '../../domain/entities/device_contact_entity.dart';
import '../utils/phone_hasher.dart';

/// Flattens a device [Contact] into one [DeviceContactEntity] per phone
/// number it has (a contact can have more than one number, and each is
/// independently hashed/synced/matched).
List<DeviceContactEntity> deviceContactEntitiesFrom(Contact contact) {
  final name = contact.displayName;
  if (name == null || name.isEmpty) return const [];

  return contact.phones
      .map((phone) {
        final normalized = normalizePhoneDigits(phone.number);
        if (normalized.isEmpty) return null;
        return DeviceContactEntity(
          name: name,
          rawPhone: phone.number,
          normalizedPhone: normalized,
          hashedNumber: hashPhone(normalized),
        );
      })
      .whereType<DeviceContactEntity>()
      .toList();
}
