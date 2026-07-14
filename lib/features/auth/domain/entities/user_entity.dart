class UserEntity {
  final String id;
  final String name;
  final String phone;
  final String memberSince;
  final double rating;
  final int totalPosts;
  final int activePosts;
  final int mutualConnections;
  final int callsMade;
  final int responseRate;

  const UserEntity({
    required this.id,
    required this.name,
    required this.phone,
    required this.memberSince,
    required this.rating,
    required this.totalPosts,
    required this.activePosts,
    required this.mutualConnections,
    required this.callsMade,
    required this.responseRate,
  });
}
