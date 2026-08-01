import 'package:dio/dio.dart';
import '../../../../core/network/api_exception.dart';
import '../../../scratch_cards/data/models/scratch_card_model.dart';
import '../../../search/domain/entities/location_entity.dart';
import '../../domain/entities/post_entity.dart';
import '../models/post_model.dart';

abstract class PostRemoteDataSource {
  Future<PostSubmitResult> submitPost({
    required String userId,
    required String vehicleId,
    required LocationEntity origin,
    required List<LocationEntity> destinations,
    required LocationEntity currentLocation,
    String? contactName,
    String? contactNumber,
  });
}

class PostRemoteDataSourceImpl implements PostRemoteDataSource {
  final Dio _dio;

  PostRemoteDataSourceImpl(this._dio);

  @override
  Future<PostSubmitResult> submitPost({
    required String userId,
    required String vehicleId,
    required LocationEntity origin,
    required List<LocationEntity> destinations,
    required LocationEntity currentLocation,
    String? contactName,
    String? contactNumber,
  }) async {
    try {
      final response = await _dio.post(
        '/api/posts/create/$userId',
        data: {
          'vehicleId': vehicleId,
          'origin': origin.toRequestJson(),
          'destinations': destinations.map((d) => d.toRequestJson()).toList(),
          'currentLocation': currentLocation.toRequestJson(),
          'contactName': ?contactName,
          'contactNumber': ?contactNumber,
        },
      );
      final data = response.data as Map<String, dynamic>;
      final post = PostModel.fromJson(data['post'] as Map<String, dynamic>);
      // `scratchCard` is only ever non-null when `scratchCardEarned` is true
      // (at most one per user per UTC day) — the two fields are redundant,
      // so a non-null card is all that's needed to decide whether to route
      // through the reveal screen.
      final scratchCardJson = data['scratchCard'] as Map<String, dynamic>?;
      final scratchCard = scratchCardJson != null
          ? ScratchCardModel.fromJson(scratchCardJson)
          : null;
      return (post: post, scratchCard: scratchCard);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (_) {
      throw const ApiException();
    }
  }
}
