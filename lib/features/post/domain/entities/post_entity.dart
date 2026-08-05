import '../../../scratch_cards/domain/entities/scratch_card_entity.dart';

typedef PostSubmitResult = ({PostEntity post, ScratchCardEntity? scratchCard});

class PostEntity {
  final String id;
  final String vehicleId;
  final String vehicleNumber;
  final String truckType;
  final int capacity;
  final double? length;
  final double? height;
  final String originName;
  final List<String> destinationNames;
  final String status;
  final DateTime createdAt;
  final String? contactName;
  final String? contactNumber;

  const PostEntity({
    required this.id,
    required this.vehicleId,
    required this.vehicleNumber,
    required this.truckType,
    required this.capacity,
    this.length,
    this.height,
    required this.originName,
    required this.destinationNames,
    required this.status,
    required this.createdAt,
    this.contactName,
    this.contactNumber,
  });
}
