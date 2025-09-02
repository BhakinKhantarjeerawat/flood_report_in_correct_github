import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/location_provider.dart';
import '../utils/snackbar_utils.dart';

class MapErrorWidget extends ConsumerWidget {
  final Object error;

  const MapErrorWidget({
    super.key,
    required this.error,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error loading map: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(currentLocationProvider.notifier).refreshLocation();
                SnackBarUtils.showInfo(context, 'Refreshing location...');
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
