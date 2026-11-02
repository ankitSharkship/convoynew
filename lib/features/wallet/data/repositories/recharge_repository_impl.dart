import '../../../../core/network/api_exception.dart';
import '../../domain/entities/recharge_entities.dart';
import '../../domain/repositories/recharge_repository.dart';
import '../datasources/recharge_remote_datasource.dart';

class RechargeRepositoryImpl implements RechargeRepository {
  final RechargeRemoteDataSource _remote;
  final Future<String?> Function() _userId;

  RechargeRepositoryImpl(this._remote, this._userId);

  Future<String> _requireUser() async {
    final id = await _userId();
    if (id == null) throw const ApiException();
    return id;
  }

  @override
  Future<RechargeConfig> getConfig() => _remote.getConfig();

  @override
  Future<RechargeOrder> create(int amountRupees) async =>
      _remote.create(await _requireUser(), amountRupees);

  @override
  Future<RechargeOrder> confirm(PaymentProof proof) async =>
      _remote.confirm(await _requireUser(), proof);

  @override
  Future<RechargeOrder> get(String orderId) async =>
      _remote.get(await _requireUser(), orderId);
}
