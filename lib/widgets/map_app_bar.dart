import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/marker_provider.dart';
import '../providers/user_provider.dart';
import '../screeens/auth_screen.dart';
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
      actions: [
        // User info and sign out button
        Consumer(
          builder: (context, ref, child) {
            final currentUser = ref.watch(userProvider);
            
            return PopupMenuButton<String>(
              icon: const Icon(Icons.account_circle),
              tooltip: 'User menu',
              onSelected: (value) async {
                if (value == 'signout') {
                  await _showSignOutDialog(context, ref);
                }
              },
              itemBuilder: (context) => [
                // User info
                if (currentUser != null) ...[
                  PopupMenuItem<String>(
                    enabled: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Signed in as:',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        Text(
                          currentUser.displayName ?? 'Anonymous User',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'ID: ${currentUser.id.substring(0, 8)}...',
                          style: TextStyle(
                            fontSize: 10,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                ],
                // Sign out option
                const PopupMenuItem<String>(
                  value: 'signout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, size: 18),
                      SizedBox(width: 8),
                      Text('Sign Out'),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Future<void> _showSignOutDialog(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text(
          'Are you sure you want to sign out? You will lose access to your flood reports.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final userNotifier = ref.read(userProvider.notifier);
        await userNotifier.signOut();
        
        // Navigate back to auth screen
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/auth',
          (route) => false,
        );
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Signed out successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error signing out: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
