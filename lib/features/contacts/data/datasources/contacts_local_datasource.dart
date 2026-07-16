import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/device_contact_entity.dart';

abstract class ContactsLocalDataSource {
  DateTime? getLastSyncTime();
  Future<void> saveLastSyncTime(DateTime time);

  Future<void> saveHashLookup(List<DeviceContactEntity> contacts);
  ({String name, String phone})? lookupByHash(String hashedNumber);
}

class ContactsLocalDataSourceImpl implements ContactsLocalDataSource {
  static const _lastSyncKey = 'contacts_last_sync_at';
  static const _hashLookupKey = 'contacts_hash_to_contact_cache';

  final SharedPreferences _prefs;

  ContactsLocalDataSourceImpl(this._prefs);

  @override
  DateTime? getLastSyncTime() {
    final raw = _prefs.getString(_lastSyncKey);
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  @override
  Future<void> saveLastSyncTime(DateTime time) async {
    await _prefs.setString(_lastSyncKey, time.toIso8601String());
  }

  @override
  Future<void> saveHashLookup(List<DeviceContactEntity> contacts) async {
    final map = <String, dynamic>{
      for (final contact in contacts)
        contact.hashedNumber: {'name': contact.name, 'phone': contact.rawPhone},
    };
    await _prefs.setString(_hashLookupKey, jsonEncode(map));
  }

  @override
  ({String name, String phone})? lookupByHash(String hashedNumber) {
    final raw = _prefs.getString(_hashLookupKey);
    if (raw == null) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final entry = map[hashedNumber] as Map<String, dynamic>?;
      if (entry == null) return null;
      return (
        name: entry['name'] as String? ?? '',
        phone: entry['phone'] as String? ?? '',
      );
    } catch (_) {
      return null;
    }
  }
}
