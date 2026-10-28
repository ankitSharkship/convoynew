import '../../../search/domain/entities/truck_search_result_entity.dart';
import '../entities/geo_box.dart';
import '../entities/truck_pin_entity.dart';
import '../repositories/truck_pins_repository.dart';

class GetTruckPinsUseCase {
  final TruckPinsRepository _repository;

  GetTruckPinsUseCase(this._repository);

  Future<TruckPinsEntity> execute(GeoBox box) => _repository.getPins(box);
}

class GetTruckPostDetailUseCase {
  final TruckPinsRepository _repository;

  GetTruckPostDetailUseCase(this._repository);

  Future<TruckSearchResultEntity> execute(String postId) =>
      _repository.getPostDetail(postId);
}
