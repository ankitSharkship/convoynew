import 'truck_listing_entity.dart';

class HomeDataEntity {
  final List<TruckListingEntity> nearbyTrucks;
  final List<RecentPostEntity> recentPosts;

  const HomeDataEntity({
    required this.nearbyTrucks,
    required this.recentPosts,
  });
}

class RecentPostEntity {
  final String id;
  final String origin;
  final String destination;
  final String vehicleNumber;
  final String postedDate;

  const RecentPostEntity({
    required this.id,
    required this.origin,
    required this.destination,
    required this.vehicleNumber,
    required this.postedDate,
  });
}
