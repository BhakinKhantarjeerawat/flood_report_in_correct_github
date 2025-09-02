import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for marker filter state
final markerFilterProvider = StateProvider<bool>((ref) => true); // true = filtered, false = all

class MarkerFilterToggle extends ConsumerWidget {
  const MarkerFilterToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFiltered = ref.watch(markerFilterProvider);
    
    return Container(
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Filtered Option (200km)
          GestureDetector(
            onTap: () => ref.read(markerFilterProvider.notifier).state = true,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: isFiltered ? Colors.blue : Colors.transparent,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8.0),
                  bottomLeft: Radius.circular(8.0),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.filter_list,
                    size: 16,
                    color: isFiltered ? Colors.white : Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '200km',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isFiltered ? Colors.white : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // All Markers Option
          GestureDetector(
            onTap: () => ref.read(markerFilterProvider.notifier).state = false,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: !isFiltered ? Colors.blue : Colors.transparent,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(8.0),
                  bottomRight: Radius.circular(8.0),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.public,
                    size: 16,
                    color: !isFiltered ? Colors.white : Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'All',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: !isFiltered ? Colors.white : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
