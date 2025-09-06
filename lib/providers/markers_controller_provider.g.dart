// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'markers_controller_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$convertFloodsToMarkersHash() =>
    r'4da0ab08028754c8ee4d8c332e15468955f8ebe6';

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
String _$markersControllerHash() => r'f02d5f1522b863dbf1f2f467a1d683adeb221b0c';

/// See also [MarkersController].
@ProviderFor(MarkersController)
final markersControllerProvider =
    AutoDisposeAsyncNotifierProvider<MarkersController, List<Flood>>.internal(
  MarkersController.new,
  name: r'markersControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$markersControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$MarkersController = AutoDisposeAsyncNotifier<List<Flood>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
