import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/flood.dart';
import '../providers/marker_provider.dart';
import '../screeens/flood_report_form.dart';
import '../utils/snackbar_utils.dart';

class MapFloatingActions extends ConsumerWidget {
  final VoidCallback onGoToCurrentLocation;
  final bool hasGoneToCurrentLocation;

  const MapFloatingActions({
    super.key,
    required this.onGoToCurrentLocation,
    required this.hasGoneToCurrentLocation,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Go to Current Location Button (Toggle between close and wide view)
        FloatingActionButton(
          onPressed: onGoToCurrentLocation,
          backgroundColor: hasGoneToCurrentLocation ? Colors.orange : Colors.white,
          foregroundColor: hasGoneToCurrentLocation ? Colors.white : Colors.blue,
          heroTag: 'currentLocation',
          child: Icon(
            hasGoneToCurrentLocation ? Icons.zoom_out : Icons.my_location,
          ),
        ),
        const SizedBox(height: 16),
        // Report Flood Button
        FloatingActionButton.extended(
          onPressed: () async {
            final result = await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const FloodReportForm(),
              ),
            );
            if (result != null && result is Flood) {
              // Add new flood report to map
              ref.read(markerProvider.notifier).addMarker(result);
              SnackBarUtils.showSuccess(context, 'New flood report added to map!');
            }
          },
          backgroundColor: const Color(0xFF1976D2),
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add_location),
          label: const Text('Report Flood'),
        ),
      ],
    );
  }
}
