import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/dio_client.dart';
import '../../domain/entities/mutual_contact_entity.dart';
import '../../domain/usecases/get_mutual_contacts_usecase.dart';
import 'contacts_sync_notifier.dart';

part 'mutual_contacts_notifier.g.dart';

@riverpod
GetMutualContactsUseCase getMutualContactsUseCase(
  GetMutualContactsUseCaseRef ref,
) => GetMutualContactsUseCase(ref.watch(contactsRepositoryProvider));

@riverpod
Future<List<MutualContactEntity>> mutualContacts(
  MutualContactsRef ref, {
  required String otherUserId,
}) async {
  final searcherUserId = await ref.read(tokenStorageProvider).getUserId();
  if (searcherUserId == null) return const [];
  return ref
      .read(getMutualContactsUseCaseProvider)
      .execute(searcherUserId: searcherUserId, otherUserId: otherUserId);
}
