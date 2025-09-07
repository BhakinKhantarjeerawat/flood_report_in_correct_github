import 'package:flood_marker/models/flood.dart';
import 'package:flood_marker/providers/markers_controller_provider.dart';
import 'package:flood_marker/screeens/map_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MarkerPopup extends ConsumerWidget {
  final Flood flood;
  final VoidCallback onClose;

  const MarkerPopup({
    super.key,
    required this.flood,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: Colors.blue,
                    size: 24,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Marker Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: onClose,
                icon: const Icon(Icons.close),
                iconSize: 20,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Location coordinates
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                            onPressed: () {
                              ref
                                  .read(floodsControllerProvider.notifier)
                                  .deleteFlood(flood.id);
                              ref.read(selectedMarkerProvider.notifier).state =
                                  null;
                            },
                            icon: const Icon(Icons.delete)),
                      ],
                    ),
                    Text(
                      'ID: ${flood.id}',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    Text(
                      'UserID: ${flood.userId}',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    Text(
                      'Status: ${flood.status}',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const Text("-----------------"),
                    Text(
                      'Latitude: ${flood.lat.toStringAsFixed(6)}',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    Text(
                      'Longitude: ${flood.lng.toStringAsFixed(6)}',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    Text(
                      'Depth: ${flood.depthCm}',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    Text(
                      'ExpiresAt: ${flood.expiresAt}',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    Text(
                      'CreatedAt: ${flood.createdAt}',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    Text(
                      'Confirms: ${flood.confirms}',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: onClose,
                child: const Text('Close'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
