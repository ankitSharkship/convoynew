import '../../domain/entities/device_contact_entity.dart';
import '../../domain/entities/mutual_contact_entity.dart';
import '../../domain/repositories/contacts_repository.dart';
import '../datasources/contacts_device_datasource.dart';
import '../datasources/contacts_local_datasource.dart';
import '../datasources/contacts_remote_datasource.dart';
import '../models/device_contact_model.dart';

class ContactsRepositoryImpl implements ContactsRepository {
  final ContactsDeviceDataSource _device;
  final ContactsLocalDataSource _local;
  final ContactsRemoteDataSource _remote;

  ContactsRepositoryImpl(this._device, this._local, this._remote);

  @override
  Future<bool> hasPermission() => _device.hasPermission();

  @override
  Future<bool> requestPermission() => _device.requestPermission();

  @override
  Future<List<DeviceContactEntity>> readDeviceContacts() async {
    final contacts = await _device.readContacts();
    return contacts.expand(deviceContactEntitiesFrom).toList();
  }

  @override
  Future<void> syncContacts({
    required String userId,
    required List<DeviceContactEntity> contacts,
  }) => _remote.syncContacts(userId: userId, contacts: contacts);

  @override
  Future<List<MutualContactEntity>> getMutualContacts({
    required String searcherUserId,
    required String otherUserId,
  }) => _remote.getMutualContacts(
    searcherUserId: searcherUserId,
    otherUserId: otherUserId,
  );

  @override
  DateTime? getLastSyncTime() => _local.getLastSyncTime();

  @override
  Future<void> markSynced(DateTime time) => _local.saveLastSyncTime(time);

  @override
  Future<void> saveHashLookupCache(List<DeviceContactEntity> contacts) =>
      _local.saveHashLookup(contacts);

  @override
  ({String name, String phone})? lookupByHash(String hashedNumber) =>
      _local.lookupByHash(hashedNumber);
}
