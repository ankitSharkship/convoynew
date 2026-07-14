// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$vehicleLocalDataSourceHash() =>
    r'b5a7e3786ca393350c42ae3315f469337ce799ad';

/// See also [vehicleLocalDataSource].
@ProviderFor(vehicleLocalDataSource)
final vehicleLocalDataSourceProvider =
    AutoDisposeProvider<VehicleLocalDataSource>.internal(
      vehicleLocalDataSource,
      name: r'vehicleLocalDataSourceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$vehicleLocalDataSourceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef VehicleLocalDataSourceRef =
    AutoDisposeProviderRef<VehicleLocalDataSource>;
String _$vehicleNotifierHash() => r'dea47e1506ed5430bbd12eea5eba448fbeab7881';

/// See also [VehicleNotifier].
@ProviderFor(VehicleNotifier)
final vehicleNotifierProvider =
    AutoDisposeAsyncNotifierProvider<
      VehicleNotifier,
      List<VehicleModel>
    >.internal(
      VehicleNotifier.new,
      name: r'vehicleNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$vehicleNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$VehicleNotifier = AutoDisposeAsyncNotifier<List<VehicleModel>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
