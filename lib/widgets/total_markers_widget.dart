import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

class TotalMarkersWidget extends StatelessWidget {
  const TotalMarkersWidget({
    super.key,
    required List<Marker> filteredMarkers,
    required List<Marker> markers,
  }) : _filteredMarkers = filteredMarkers, _markers = markers;

  final List<Marker> _filteredMarkers;
  final List<Marker> _markers;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 40, // Above the floating action buttons
      left: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.blue.withOpacity(0.3), width: 2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.location_on,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Total Reports',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  '${_filteredMarkers.length}/${_markers.length}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _filteredMarkers.length < _markers.length ? Colors.orange : Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
