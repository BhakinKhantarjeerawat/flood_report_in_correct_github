import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/flood.dart';

class FloodMarkerPopup extends ConsumerWidget {
  final Flood flood;
  final VoidCallback onClose;

  const FloodMarkerPopup({
    super.key,
    required this.flood,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final severityColor = _getSeverityColor(flood.severity);
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: severityColor,
          width: 3,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with severity and close button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    _getSeverityIcon(flood.severity),
                    color: _getSeverityColor(flood.severity),
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getSeverityText(flood.severity),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _getSeverityColor(flood.severity),
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
          const SizedBox(height: 12),
          
          // Location
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${flood.lat.toStringAsFixed(4)}, ${flood.lng.toStringAsFixed(4)}',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Water depth
          if (flood.depthCm != null) ...[
            Row(
              children: [
                const Icon(Icons.water_drop, size: 16, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Depth: ${flood.depthCm}cm',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          // Description
          if (flood.note != null && flood.note!.isNotEmpty) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.description, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    flood.note!,
                    style: const TextStyle(fontSize: 14),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          
          // Timestamp
          Row(
            children: [
              const Icon(Icons.access_time, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                _formatTimestamp(flood.createdAt),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
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

  IconData _getSeverityIcon(String severity) {
    switch (severity.toLowerCase()) {
      case 'passable':
        return Icons.check_circle;
      case 'blocked':
        return Icons.block;
      case 'severe':
        return Icons.dangerous;
      case 'low':
        return Icons.info;
      case 'medium':
        return Icons.warning;
      case 'high':
        return Icons.error;
      default:
        return Icons.info;
    }
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'passable':
        return Colors.green;
      case 'blocked':
        return Colors.orange;
      case 'severe':
        return Colors.red;
      case 'low':
        return Colors.white;
      case 'medium':
        return Colors.white;
      case 'high':
        return Colors.white;
      default:
        return Colors.blue;
    }
  }

  String _getSeverityText(String severity) {
    switch (severity.toLowerCase()) {
      case 'passable':
        return 'Passable';
      case 'blocked':
        return 'Blocked';
      case 'severe':
        return 'Severe Flooding';
      case 'low':
        return 'Low Risk';
      case 'medium':
        return 'Medium Risk';
      case 'high':
        return 'High Risk';
      default:
        return 'Unknown Risk';
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
}
