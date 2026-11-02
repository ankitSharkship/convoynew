import '../entities/call_request_entity.dart';
import '../repositories/call_request_repository.dart';

class CreateCallRequestUseCase {
  final CallRequestRepository _repository;

  CreateCallRequestUseCase(this._repository);

  Future<CallRequestEntity> execute({
    required String providerId,
    required String truckRouteId,
    required String topic,
    required int durationMinutes,
    required int amountRupees,
  }) => _repository.create(
    providerId: providerId,
    truckRouteId: truckRouteId,
    topic: topic,
    durationMinutes: durationMinutes,
    amountRupees: amountRupees,
  );
}

class GetCallRequestUseCase {
  final CallRequestRepository _repository;

  GetCallRequestUseCase(this._repository);

  Future<CallRequestEntity> execute(String requestId) =>
      _repository.get(requestId);
}

class CancelCallRequestUseCase {
  final CallRequestRepository _repository;

  CancelCallRequestUseCase(this._repository);

  Future<CallRequestEntity> execute(String requestId) =>
      _repository.cancel(requestId);
}

class GetIncomingCallRequestsUseCase {
  final CallRequestRepository _repository;

  GetIncomingCallRequestsUseCase(this._repository);

  Future<List<CallRequestEntity>> execute() => _repository.getIncoming();
}

class AcceptCallRequestUseCase {
  final CallRequestRepository _repository;

  AcceptCallRequestUseCase(this._repository);

  Future<CallRequestEntity> execute(String requestId) =>
      _repository.accept(requestId);
}

class RejectCallRequestUseCase {
  final CallRequestRepository _repository;

  RejectCallRequestUseCase(this._repository);

  Future<CallRequestEntity> execute(String requestId) =>
      _repository.reject(requestId);
}
