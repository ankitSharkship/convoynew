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
  /// than [_staleAfter] (or [force] is true). No-ops otherwise. Intended to
  /// be called after login and on app resume — a mobile client with no
  /// background-isolate infra, so this "check when the app is in the
  /// foreground" approach is the periodic-refresh mechanism.
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
