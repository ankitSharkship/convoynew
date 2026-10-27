import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/my_uploads_entity.dart';
import '../../domain/usecases/get_reels_usecase.dart';
import 'reels_notifier.dart';

part 'my_uploads_notifier.g.dart';

@riverpod
GetMyUploadsUseCase getMyUploadsUseCase(GetMyUploadsUseCaseRef ref) {
  return GetMyUploadsUseCase(ref.watch(reelsRepositoryProvider));
}

/// The signed-in user's own uploads (every status) plus creator totals.
@riverpod
Future<MyUploadsEntity> myUploads(MyUploadsRef ref) {
  return ref.watch(getMyUploadsUseCaseProvider).execute();
}
