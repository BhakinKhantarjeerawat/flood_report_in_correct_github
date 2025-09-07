// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'floods_controller_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$convertFloodsToMarkersHash() =>
    r'733ded8cf29ff46a7ce13e07f6c108fb763a1989';

/// See also [convertFloodsToMarkers].
@ProviderFor(convertFloodsToMarkers)
final convertFloodsToMarkersProvider =
    AutoDisposeFutureProvider<List<Marker>>.internal(
  convertFloodsToMarkers,
  name: r'convertFloodsToMarkersProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$convertFloodsToMarkersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ConvertFloodsToMarkersRef = AutoDisposeFutureProviderRef<List<Marker>>;
String _$floodsControllerHash() => r'606df97a440b8628a76cc64409bf71a1be92f3ff';

/// See also [FloodsController].
@ProviderFor(FloodsController)
final floodsControllerProvider =
    AutoDisposeAsyncNotifierProvider<FloodsController, List<Flood>>.internal(
  FloodsController.new,
  name: r'floodsControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$floodsControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$FloodsController = AutoDisposeAsyncNotifier<List<Flood>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
