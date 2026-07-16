import '../entities/device_contact_entity.dart';
import '../entities/mutual_contact_entity.dart';

abstract class ContactsRepository {
  Future<bool> hasPermission();
  Future<bool> requestPermission();

  /// Reads the device's contacts and returns them hashed, ready to sync.
  Future<List<DeviceContactEntity>> readDeviceContacts();

  Future<void> syncContacts({
    required String userId,
    required List<DeviceContactEntity> contacts,
  });

  Future<List<MutualContactEntity>> getMutualContacts({
    required String searcherUserId,
    required String otherUserId,
  });

  DateTime? getLastSyncTime();
  Future<void> markSynced(DateTime time);

  /// Caches a hash -> {name, phone} lookup built from [contacts], so that
  /// mutual-contact hashes returned by the server can later be resolved
  /// back to a real, dialable number without ever sending numbers up.
  Future<void> saveHashLookupCache(List<DeviceContactEntity> contacts);

  ({String name, String phone})? lookupByHash(String hashedNumber);
}
