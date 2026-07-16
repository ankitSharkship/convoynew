import '../repositories/contacts_repository.dart';

class SyncContactsUseCase {
  final ContactsRepository _repository;

  SyncContactsUseCase(this._repository);

  /// Reads the device's contacts, caches a local hash lookup for later
  /// resolving mutual-contact hashes back to real numbers, and syncs the
  /// hashed contacts to the backend for [userId].
  Future<void> execute({required String userId}) async {
    final contacts = await _repository.readDeviceContacts();
    await _repository.saveHashLookupCache(contacts);
    await _repository.syncContacts(userId: userId, contacts: contacts);
    await _repository.markSynced(DateTime.now());
  }
}
