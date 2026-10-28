import '../../../search/domain/entities/truck_search_result_entity.dart';
import '../entities/geo_box.dart';
import '../entities/truck_pin_entity.dart';

abstract class TruckPinsRepository {
  Future<TruckPinsEntity> getPins(GeoBox box);

  /// Throws [TruckPostUnavailableException] if the post is no longer live.
  Future<TruckSearchResultEntity> getPostDetail(String postId);
}
