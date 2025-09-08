// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flood_report_screen1.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$currentLocationControllerHash() =>
    r'c016b30c681b03f1c9683bf5570d3f1aa23dcc06';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$CurrentLocationController
    extends BuildlessAsyncNotifier<LatLng> {
  late final bool useMockLocation;

  FutureOr<LatLng> build(
    bool useMockLocation,
  );
}

/// See also [CurrentLocationController].
@ProviderFor(CurrentLocationController)
const currentLocationControllerProvider = CurrentLocationControllerFamily();

/// See also [CurrentLocationController].
class CurrentLocationControllerFamily extends Family<AsyncValue<LatLng>> {
  /// See also [CurrentLocationController].
  const CurrentLocationControllerFamily();

  /// See also [CurrentLocationController].
  CurrentLocationControllerProvider call(
    bool useMockLocation,
  ) {
    return CurrentLocationControllerProvider(
      useMockLocation,
    );
  }

  @override
  CurrentLocationControllerProvider getProviderOverride(
    covariant CurrentLocationControllerProvider provider,
  ) {
    return call(
      provider.useMockLocation,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'currentLocationControllerProvider';
}

/// See also [CurrentLocationController].
class CurrentLocationControllerProvider
    extends AsyncNotifierProviderImpl<CurrentLocationController, LatLng> {
  /// See also [CurrentLocationController].
  CurrentLocationControllerProvider(
    bool useMockLocation,
  ) : this._internal(
          () => CurrentLocationController()..useMockLocation = useMockLocation,
          from: currentLocationControllerProvider,
          name: r'currentLocationControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$currentLocationControllerHash,
          dependencies: CurrentLocationControllerFamily._dependencies,
          allTransitiveDependencies:
              CurrentLocationControllerFamily._allTransitiveDependencies,
          useMockLocation: useMockLocation,
        );

  CurrentLocationControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.useMockLocation,
  }) : super.internal();

  final bool useMockLocation;

  @override
  FutureOr<LatLng> runNotifierBuild(
    covariant CurrentLocationController notifier,
  ) {
    return notifier.build(
      useMockLocation,
    );
  }

  @override
  Override overrideWith(CurrentLocationController Function() create) {
    return ProviderOverride(
      origin: this,
      override: CurrentLocationControllerProvider._internal(
        () => create()..useMockLocation = useMockLocation,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        useMockLocation: useMockLocation,
      ),
    );
  }

  @override
  AsyncNotifierProviderElement<CurrentLocationController, LatLng>
      createElement() {
    return _CurrentLocationControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CurrentLocationControllerProvider &&
        other.useMockLocation == useMockLocation;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, useMockLocation.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CurrentLocationControllerRef on AsyncNotifierProviderRef<LatLng> {
  /// The parameter `useMockLocation` of this provider.
  bool get useMockLocation;
}

class _CurrentLocationControllerProviderElement
    extends AsyncNotifierProviderElement<CurrentLocationController, LatLng>
    with CurrentLocationControllerRef {
  _CurrentLocationControllerProviderElement(super.provider);

  @override
  bool get useMockLocation =>
      (origin as CurrentLocationControllerProvider).useMockLocation;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
