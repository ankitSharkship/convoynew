import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/router/app_router.dart';
import '../../data/datasources/post_local_datasource.dart';
import '../../data/repositories/post_repository_impl.dart';
import '../../domain/entities/post_entity.dart';
import '../../domain/usecases/submit_post_usecase.dart';

part 'post_notifier.g.dart';

@riverpod
PostLocalDataSource postLocalDataSource(PostLocalDataSourceRef ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return PostLocalDataSourceImpl(prefs);
}

@riverpod
PostRepositoryImpl postRepository(PostRepositoryRef ref) {
  return PostRepositoryImpl(ref.watch(postLocalDataSourceProvider));
}

@riverpod
SubmitPostUseCase submitPostUseCase(SubmitPostUseCaseRef ref) {
  return SubmitPostUseCase(ref.watch(postRepositoryProvider));
}

sealed class PostState {
  const PostState();
}

class PostIdle extends PostState {
  const PostIdle();
}

class PostSubmitting extends PostState {
  const PostSubmitting();
}

class PostDone extends PostState {
  final PostEntity post;
  const PostDone(this.post);
}

class PostError extends PostState {
  final String message;
  const PostError(this.message);
}

@riverpod
class PostNotifier extends _$PostNotifier {
  @override
  PostState build() => const PostIdle();

  Future<void> submitPost({
    required String truckType,
    required String capacity,
    required String origin,
    required String destination,
    required String vehicleNumber,
  }) async {
    state = const PostSubmitting();
    try {
      final useCase = ref.read(submitPostUseCaseProvider);
      final post = await useCase.execute(
        truckType: truckType,
        capacity: capacity,
        origin: origin,
        destination: destination,
        vehicleNumber: vehicleNumber,
      );
      state = PostDone(post);
    } catch (e) {
      state = PostError(e.toString());
    }
  }

  void reset() => state = const PostIdle();
}
