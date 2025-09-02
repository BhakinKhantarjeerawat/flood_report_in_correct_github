import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flood_marker/providers/map_navigation_provider.dart';

void main() {
  group('MapNavigationProvider', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is correct', () {
      final state = container.read(mapNavigationProvider);
      
      expect(state.isMapReady, false);
      expect(state.hasGoneToCurrentLocation, false);
    });

    test('setMapReady updates isMapReady to true', () {
      final notifier = container.read(mapNavigationProvider.notifier);
      
      notifier.setMapReady();
      
      final state = container.read(mapNavigationProvider);
      expect(state.isMapReady, true);
      expect(state.hasGoneToCurrentLocation, false);
    });

    test('toggleLocationView toggles hasGoneToCurrentLocation', () {
      final notifier = container.read(mapNavigationProvider.notifier);
      
      // First toggle
      notifier.toggleLocationView();
      expect(container.read(mapNavigationProvider).hasGoneToCurrentLocation, true);
      
      // Second toggle
      notifier.toggleLocationView();
      expect(container.read(mapNavigationProvider).hasGoneToCurrentLocation, false);
    });

    test('resetLocationState sets hasGoneToCurrentLocation to false', () {
      final notifier = container.read(mapNavigationProvider.notifier);
      
      // Set to true first
      notifier.toggleLocationView();
      expect(container.read(mapNavigationProvider).hasGoneToCurrentLocation, true);
      
      // Reset
      notifier.resetLocationState();
      expect(container.read(mapNavigationProvider).hasGoneToCurrentLocation, false);
    });

    test('getter methods return correct values', () {
      final notifier = container.read(mapNavigationProvider.notifier);
      
      expect(notifier.isMapReady, false);
      expect(notifier.hasGoneToCurrentLocation, false);
      
      notifier.setMapReady();
      notifier.toggleLocationView();
      
      expect(notifier.isMapReady, true);
      expect(notifier.hasGoneToCurrentLocation, true);
    });
  });
}
