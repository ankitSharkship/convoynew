import '../repositories/contacts_repository.dart';
import '../entities/mutual_contact_entity.dart';

class GetMutualContactsUseCase {
  final ContactsRepository _repository;

  GetMutualContactsUseCase(this._repository);

  /// Fetches the mutual contacts between [searcherUserId] (the logged-in
  /// user) and [otherUserId] (the post owner), then resolves each hash to
  /// a real phone number using the locally-cached hash lookup — the
  /// server only ever knows the hash, never the number.
  Future<List<MutualContactEntity>> execute({
    required String searcherUserId,
    required String otherUserId,
  }) async {
    final mutuals = await _repository.getMutualContacts(
      searcherUserId: searcherUserId,
      otherUserId: otherUserId,
    );
    return mutuals.map((contact) {
      final match = _repository.lookupByHash(contact.hashedNumber);
      if (match == null) return contact;
      return contact.copyWith(phoneNumber: match.phone);
    }).toList();
  }
}
