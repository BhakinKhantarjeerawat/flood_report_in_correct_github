import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/marker_provider.dart';
import '../widgets/marker_filter_toggle.dart';

class MapAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const MapAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppBar(
      title: Consumer(
        builder: (context, ref, child) {
          final allMarkers = ref.watch(markerProvider);
          final displayMarkers = ref.watch(displayMarkersProvider);
          final isFiltered = ref.watch(markerFilterProvider);
          final filterText = isFiltered ? '200km' : 'All';
          return Text('Markers: ${displayMarkers.length}/${allMarkers.length} ($filterText)');
        },
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
