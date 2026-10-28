import '../../../search/domain/entities/truck_search_result_entity.dart';
import '../../domain/entities/geo_box.dart';
import '../../domain/entities/truck_pin_entity.dart';
import '../../domain/repositories/truck_pins_repository.dart';
import '../datasources/truck_pins_remote_datasource.dart';

class TruckPinsRepositoryImpl implements TruckPinsRepository {
  final TruckPinsRemoteDataSource _remote;

  TruckPinsRepositoryImpl(this._remote);

  @override
  Future<TruckPinsEntity> getPins(GeoBox box) => _remote.getPins(box);

  @override
  Future<TruckSearchResultEntity> getPostDetail(String postId) =>
      _remote.getPostDetail(postId);
}
