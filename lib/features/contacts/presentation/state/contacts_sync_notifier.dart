import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/router/app_router.dart';
import '../../data/datasources/contacts_device_datasource.dart';
import '../../data/datasources/contacts_local_datasource.dart';
import '../../data/datasources/contacts_remote_datasource.dart';
import '../../data/repositories/contacts_repository_impl.dart';
import '../../domain/repositories/contacts_repository.dart';
import '../../domain/usecases/sync_contacts_usecase.dart';

part 'contacts_sync_notifier.g.dart';

const _staleAfter = Duration(hours: 24);

@riverpod
ContactsDeviceDataSource contactsDeviceDataSource(
  ContactsDeviceDataSourceRef ref,
) => ContactsDeviceDataSourceImpl();

@riverpod
ContactsLocalDataSource contactsLocalDataSource(
  ContactsLocalDataSourceRef ref,
) => ContactsLocalDataSourceImpl(ref.watch(sharedPreferencesProvider));

@riverpod
ContactsRemoteDataSource contactsRemoteDataSource(
  ContactsRemoteDataSourceRef ref,
) => ContactsRemoteDataSourceImpl(ref.watch(dioProvider));

@riverpod
ContactsRepository contactsRepository(ContactsRepositoryRef ref) =>
    ContactsRepositoryImpl(
      ref.watch(contactsDeviceDataSourceProvider),
      ref.watch(contactsLocalDataSourceProvider),
      ref.watch(contactsRemoteDataSourceProvider),
    );

@riverpod
SyncContactsUseCase syncContactsUseCase(SyncContactsUseCaseRef ref) =>
    SyncContactsUseCase(ref.watch(contactsRepositoryProvider));

/// Whether contacts permission is currently granted — used to decide
/// whether the mutual-connections UI has any way to resolve a match, since
/// a granted-then-later-revoked permission leaves no path to show it.
@riverpod
Future<bool> hasContactsPermission(HasContactsPermissionRef ref) =>
    ref.watch(contactsRepositoryProvider).hasPermission();

enum ContactsSyncStatus { idle, syncing, success, permissionDenied, error }

class ContactsSyncState {
  final ContactsSyncStatus status;
  final String? errorMessage;

  const ContactsSyncState({required this.status, this.errorMessage});
}

@riverpod
class ContactsSyncNotifier extends _$ContactsSyncNotifier {
  @override
  ContactsSyncState build() =>
      const ContactsSyncState(status: ContactsSyncStatus.idle);

  /// Syncs the device's contacts to the backend if the last sync is older
  /// than [_staleAfter] (or [force] is true). No-ops otherwise. Called from
  /// three deliberate, one-shot touchpoints — right after login, once per
  /// cold app open, and when the user taps "Find Trucks" — rather than
  /// from an app-lifecycle observer, since re-requesting permission on
  /// every `resumed` event risked a feedback loop with the native
  /// permission dialog on some devices (each dialog show/dismiss could
  /// itself trigger another spurious resume).
  Future<void> syncIfStale({bool force = false}) async {
    if (state.status == ContactsSyncStatus.syncing) return;

    final repository = ref.read(contactsRepositoryProvider);
    final lastSync = repository.getLastSyncTime();
    final isStale =
        force ||
        lastSync == null ||
        DateTime.now().difference(lastSync) > _staleAfter;
    if (!isStale) return;

    state = const ContactsSyncState(status: ContactsSyncStatus.syncing);
    try {
      final granted =
          await repository.hasPermission() ||
          await repository.requestPermission();
      if (!granted) {
        state = const ContactsSyncState(
          status: ContactsSyncStatus.permissionDenied,
        );
        return;
      }

      final userId = await ref.read(tokenStorageProvider).getUserId();
      if (userId == null) {
        state = const ContactsSyncState(status: ContactsSyncStatus.idle);
        return;
      }

      await ref.read(syncContactsUseCaseProvider).execute(userId: userId);
      state = const ContactsSyncState(status: ContactsSyncStatus.success);
    } catch (e) {
      state = ContactsSyncState(
        status: ContactsSyncStatus.error,
        errorMessage: ApiException.messageFor(e),
      );
    }
  }
}
