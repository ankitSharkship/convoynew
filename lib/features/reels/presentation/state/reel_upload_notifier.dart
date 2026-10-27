import 'dart:async';

import 'package:cross_file/cross_file.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tusc/tusc.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/services/location_service.dart';
import '../../data/datasources/reel_upload_remote_datasource.dart';
import '../../data/repositories/reel_upload_repository_impl.dart';
import '../../domain/repositories/reel_upload_repository.dart';
import '../../domain/usecases/create_reel_upload_usecase.dart';

part 'reel_upload_notifier.g.dart';

/// A single sync-status call right after the TUS upload finishes almost
/// always lands before Bunny has even started transcoding, since encoding
/// only begins once Bunny has the full file — so it's retried with backoff
/// until the video turns ready/rejected/failed or this gives up. This is a
/// local-dev-only workaround: in production Bunny's own webhook
/// (routers/webhooks.py) flips the status the moment encoding finishes,
/// without any of this polling.
const _syncStatusRetryDelays = [
  Duration(seconds: 2),
  Duration(seconds: 3),
  Duration(seconds: 5),
  Duration(seconds: 5),
  Duration(seconds: 5),
  Duration(seconds: 5),
  Duration(seconds: 5),
  Duration(seconds: 5),
];
const _terminalVideoStatuses = {'ready', 'rejected', 'failed'};

@riverpod
ReelUploadRemoteDataSource reelUploadRemoteDataSource(
  ReelUploadRemoteDataSourceRef ref,
) {
  return ReelUploadRemoteDataSourceImpl(ref.watch(dioProvider));
}

@riverpod
ReelUploadRepositoryImpl reelUploadRepository(ReelUploadRepositoryRef ref) {
  return ReelUploadRepositoryImpl(ref.watch(reelUploadRemoteDataSourceProvider));
}

@riverpod
CreateReelUploadUseCase createReelUploadUseCase(
  CreateReelUploadUseCaseRef ref,
) {
  return CreateReelUploadUseCase(ref.watch(reelUploadRepositoryProvider));
}

enum ReelUploadPhase { idle, creating, uploading, completed, failed }

class ReelUploadState {
  final ReelUploadPhase phase;
  final double progress;
  final String? error;

  const ReelUploadState({
    this.phase = ReelUploadPhase.idle,
    this.progress = 0,
    this.error,
  });

  ReelUploadState copyWith({
    ReelUploadPhase? phase,
    double? progress,
    String? error,
  }) {
    return ReelUploadState(
      phase: phase ?? this.phase,
      progress: progress ?? this.progress,
      error: error,
    );
  }
}

@riverpod
class ReelUploadNotifier extends _$ReelUploadNotifier {
  @override
  ReelUploadState build() => const ReelUploadState();

  Future<void> upload({
    required String filePath,
    required String title,
    String? description,
    required List<String> categoryIds,
    List<String> hashtags = const [],
  }) async {
    state = const ReelUploadState(phase: ReelUploadPhase.creating);
    try {
      final position = await ref
          .read(locationServiceProvider)
          .getPositionIfPermitted();
      final credentials = await ref
          .read(createReelUploadUseCaseProvider)
          .execute(
            title: title,
            description: description,
            categoryIds: categoryIds,
            hashtags: hashtags,
            latitude: position?.lat,
            longitude: position?.lng,
          );

      state = state.copyWith(phase: ReelUploadPhase.uploading, progress: 0);

      final completer = Completer<void>();
      final client = TusClient(
        url: credentials.tusUploadUrl,
        file: XFile(filePath),
        headers: credentials.tusHeaders,
        metadata: const {'filetype': 'video/mp4'},
      );

      unawaited(
        client
            .startUpload(
              onProgress: (count, total, response) {
                if (total <= 0) return;
                state = state.copyWith(progress: count / total);
              },
              onComplete: (response) {
                if (!completer.isCompleted) completer.complete();
              },
              onTimeout: () {
                if (!completer.isCompleted) {
                  completer.completeError(const ApiException());
                }
              },
              onError: (error) {
                if (!completer.isCompleted) {
                  completer.completeError(ApiException(error.message));
                }
              },
            )
            .catchError((Object e) {
              // startUpload only routes *protocol* errors through onError —
              // pre-response failures (connectivity, DNS, timeouts exhausting
              // retries) are rethrown from this future instead. Without this,
              // such a failure would leave the completer (and the UI) waiting
              // forever on a future that never resolves.
              if (!completer.isCompleted) {
                completer.completeError(
                  e is ApiException ? e : const ApiException(),
                );
              }
            }),
      );

      await completer.future;
      // Captured now rather than read again inside _pollSyncStatus: this
      // notifier is autoDispose and the caller navigates away as soon as
      // `state` below flips to `completed`, so `ref` may no longer be safe
      // to use by the time a later retry iteration runs.
      final repository = ref.read(reelUploadRepositoryProvider);
      unawaited(_pollSyncStatus(repository, credentials.videoId));
      state = state.copyWith(phase: ReelUploadPhase.completed, progress: 1);
    } catch (e) {
      state = state.copyWith(
        phase: ReelUploadPhase.failed,
        error: ApiException.messageFor(e),
      );
    }
  }

  static Future<void> _pollSyncStatus(
    ReelUploadRepository repository,
    String videoId,
  ) async {
    for (final delay in _syncStatusRetryDelays) {
      await Future.delayed(delay);
      final status = await repository.syncStatus(videoId);
      if (status != null && _terminalVideoStatuses.contains(status)) return;
    }
  }
}
