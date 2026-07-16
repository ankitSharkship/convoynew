import 'package:flutter_contacts/flutter_contacts.dart';

abstract class ContactsDeviceDataSource {
  Future<bool> hasPermission();
  Future<bool> requestPermission();
  Future<List<Contact>> readContacts();
}

class ContactsDeviceDataSourceImpl implements ContactsDeviceDataSource {
  @override
  Future<bool> hasPermission() =>
      FlutterContacts.permissions.has(PermissionType.read);

  @override
  Future<bool> requestPermission() async {
    final status = await FlutterContacts.permissions.request(
      PermissionType.read,
    );
    return status == PermissionStatus.granted ||
        status == PermissionStatus.limited;
  }

  @override
  Future<List<Contact>> readContacts() =>
      FlutterContacts.getAll(properties: {ContactProperty.phone});
}
