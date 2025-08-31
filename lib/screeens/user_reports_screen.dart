// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:intl/intl.dart';
// import '../providers/user_provider.dart';
// import 'flood_report_form.dart'; // Added import for FloodReportForm

// class UserReportsScreen extends ConsumerStatefulWidget {
//   const UserReportsScreen({super.key});

//   @override
//   ConsumerState<UserReportsScreen> createState() => _UserReportsScreenState();
// }

// class _UserReportsScreenState extends ConsumerState<UserReportsScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 4, vsync: this);
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final userReportsAsync = ref.watch(userReportsProvider);
//     final userStatsAsync = ref.watch(userReportStatsProvider);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('My Flood Reports'),
//         backgroundColor: const Color(0xFF1976D2),
//         foregroundColor: Colors.white,
//         elevation: 2,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: () {
//               ref.invalidate(userReportsProvider);
//               ref.invalidate(userReportStatsProvider);
//             },
//             tooltip: 'Refresh',
//           ),
//         ],
//         bottom: TabBar(
//           controller: _tabController,
//           tabs: const [
//             Tab(text: 'All'),
//             Tab(text: 'Active'),
//             Tab(text: 'Resolved'),
//             Tab(text: 'Expired'),
//           ],
//           labelColor: Colors.white,
//           unselectedLabelColor: Colors.white70,
//           indicatorColor: Colors.white,
//         ),
//       ),
//       body: Column(
//         children: [
//           // Statistics Card
//           _buildStatisticsCard(userStatsAsync),
          
//           // Reports List
//           Expanded(
//             child: TabBarView(
//               controller: _tabController,
//               children: [
//                 _buildReportsList(userReportsAsync, 'all'),
//                 _buildReportsList(userReportsAsync, 'active'),
//                 _buildReportsList(userReportsAsync, 'resolved'),
//                 _buildReportsList(userReportsAsync, 'expired'),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatisticsCard(AsyncValue<Map<String, dynamic>> statsAsync) {
//     return Card(
//       margin: const EdgeInsets.all(16),
//       elevation: 4,
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: statsAsync.when(
//           data: (stats) {
//             final totalReports = stats['total_reports'] ?? 0;
//             final activeReports = stats['active_reports'] ?? 0;
//             final resolvedReports = stats['resolved_reports'] ?? 0;
//             final severityBreakdown = stats['severity_breakdown'] ?? <String, int>{};

//             return Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Report Summary',
//                   style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                     fontWeight: FontWeight.bold,
//                     color: const Color(0xFF1976D2),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceAround,
//                   children: [
//                     _buildStatItem('Total', totalReports.toString(), Icons.assessment),
//                     _buildStatItem('Active', activeReports.toString(), Icons.warning),
//                     _buildStatItem('Resolved', resolvedReports.toString(), Icons.check_circle),
//                   ],
//                 ),
//                 if (severityBreakdown.isNotEmpty) ...[
//                   const SizedBox(height: 16),
//                   Text(
//                     'By Severity',
//                     style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceAround,
//                     children: [
//                       _buildSeverityStat('Passable', severityBreakdown['passable'] ?? 0, Colors.green),
//                       _buildSeverityStat('Blocked', severityBreakdown['blocked'] ?? 0, Colors.orange),
//                       _buildSeverityStat('Severe', severityBreakdown['severe'] ?? 0, Colors.red),
//                     ],
//                   ),
//                 ],
//               ],
//             );
//           },
//           loading: () => const Center(child: CircularProgressIndicator()),
//           error: (error, stack) => Text('Error: $error'),
//         ),
//       ),
//     );
//   }

//   Widget _buildStatItem(String label, String value, IconData icon) {
//     return Column(
//       children: [
//         Icon(icon, size: 32, color: const Color(0xFF1976D2)),
//         const SizedBox(height: 8),
//         Text(
//           value,
//           style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//             fontWeight: FontWeight.bold,
//             color: const Color(0xFF1976D2),
//           ),
//         ),
//         Text(
//           label,
//           style: Theme.of(context).textTheme.bodySmall?.copyWith(
//             color: Colors.grey[600],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildSeverityStat(String label, int count, Color color) {
//     return Column(
//       children: [
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//           decoration: BoxDecoration(
//             color: color.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(16),
//             border: Border.all(color: color),
//           ),
//           child: Text(
//             count.toString(),
//             style: TextStyle(
//               color: color,
//               fontWeight: FontWeight.bold,
//               fontSize: 16,
//             ),
//           ),
//         ),
//         const SizedBox(height: 4),
//         Text(
//           label,
//           style: Theme.of(context).textTheme.bodySmall?.copyWith(
//             color: Colors.grey[600],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildReportsList(AsyncValue<List<Map<String, dynamic>>> reportsAsync, String status) {
//     return reportsAsync.when(
//       data: (reports) {
//         // Filter reports by status
//         final filteredReports = reports.where((report) {
//           if (status == 'all') return true;
//           return report['status'] == status;
//         }).toList();

//         if (filteredReports.isEmpty) {
//           return _buildEmptyState(status);
//         }

//         return RefreshIndicator(
//           onRefresh: () async {
//             ref.invalidate(userReportsProvider);
//             ref.invalidate(userReportStatsProvider);
//           },
//           child: ListView.builder(
//             padding: const EdgeInsets.all(16),
//             itemCount: filteredReports.length,
//             itemBuilder: (context, index) {
//               final report = filteredReports[index];
//               return _buildReportCard(report);
//             },
//           ),
//         );
//       },
//       loading: () => const Center(child: CircularProgressIndicator()),
//       error: (error, stack) => Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
//             const SizedBox(height: 16),
//             Text(
//               'Error loading reports',
//               style: Theme.of(context).textTheme.titleMedium,
//             ),
//             const SizedBox(height: 8),
//             Text(
//               error.toString(),
//               style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                 color: Colors.grey[600],
//               ),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: () {
//                 ref.invalidate(userReportsProvider);
//                 ref.invalidate(userReportStatsProvider);
//               },
//               child: const Text('Retry'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildEmptyState(String status) {
//     String message;
//     IconData icon;

//     switch (status) {
//       case 'active':
//         message = 'No active flood reports';
//         icon = Icons.check_circle_outline;
//         break;
//       case 'resolved':
//         message = 'No resolved flood reports';
//         icon = Icons.done_all;
//         break;
//       case 'expired':
//         message = 'No expired flood reports';
//         icon = Icons.schedule;
//         break;
//       default:
//         message = 'No flood reports yet';
//         icon = Icons.add_location;
//     }

//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(icon, size: 64, color: Colors.grey[400]),
//           const SizedBox(height: 16),
//           Text(
//             message,
//             style: Theme.of(context).textTheme.titleMedium?.copyWith(
//               color: Colors.grey[600],
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             status == 'all' 
//                 ? 'Submit your first flood report to get started!'
//                 : 'Reports will appear here when they match this status.',
//             style: Theme.of(context).textTheme.bodySmall?.copyWith(
//               color: Colors.grey[500],
//             ),
//             textAlign: TextAlign.center,
//           ),
//           if (status == 'all') ...[
//             const SizedBox(height: 16),
//             ElevatedButton.icon(
//               onPressed: () {
//                 Navigator.of(context).push(
//                   MaterialPageRoute(
//                     builder: (context) => const FloodReportForm(),
//                   ),
//                 );
//               },
//               icon: const Icon(Icons.add_location),
//               label: const Text('Report New Flood'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF1976D2),
//                 foregroundColor: Colors.white,
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }

//   Widget _buildReportCard(Map<String, dynamic> report) {
//     final severity = report['severity'] as String;
//     final status = report['status'] as String;
//     final createdAt = DateTime.parse(report['created_at']);
//     final expiresAt = DateTime.parse(report['expires_at']);
//     final note = report['note'] as String?;
//     final depthCm = report['depth_cm'] as int?;
//     final photoUrls = List<String>.from(report['photo_urls'] ?? []);

//     Color severityColor;
//     IconData severityIcon;
    
//     switch (severity) {
//       case 'passable':
//         severityColor = Colors.green;
//         severityIcon = Icons.directions_walk;
//         break;
//       case 'blocked':
//         severityColor = Colors.orange;
//         severityIcon = Icons.block;
//         break;
//       case 'severe':
//         severityColor = Colors.red;
//         severityIcon = Icons.warning;
//         break;
//       default:
//         severityColor = Colors.grey;
//         severityIcon = Icons.help;
//     }

//     Color statusColor;
//     IconData statusIcon;
    
//     switch (status) {
//       case 'active':
//         statusColor = Colors.green;
//         statusIcon = Icons.radio_button_checked;
//         break;
//       case 'resolved':
//         statusColor = Colors.blue;
//         statusIcon = Icons.check_circle;
//         break;
//       case 'expired':
//         statusColor = Colors.grey;
//         statusIcon = Icons.schedule;
//         break;
//       default:
//         statusColor = Colors.grey;
//         statusIcon = Icons.help;
//     }

//     return Card(
//       margin: const EdgeInsets.only(bottom: 16),
//       elevation: 2,
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Header with severity and status
//             Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: severityColor.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(color: severityColor),
//                   ),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Icon(severityIcon, size: 16, color: severityColor),
//                       const SizedBox(width: 4),
//                       Text(
//                         severity.toUpperCase(),
//                         style: TextStyle(
//                           color: severityColor,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 12,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const Spacer(),
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: statusColor.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(color: statusColor),
//                   ),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Icon(statusIcon, size: 16, color: statusColor),
//                       const SizedBox(width: 4),
//                       Text(
//                         status.toUpperCase(),
//                         style: TextStyle(
//                           color: statusColor,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 12,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
            
//             const SizedBox(height: 16),
            
//             // Location and details
//             Row(
//               children: [
//                 Icon(Icons.location_on, color: Colors.grey[600], size: 20),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: Text(
//                     '${report['lat'].toStringAsFixed(6)}, ${report['lng'].toStringAsFixed(6)}',
//                     style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
            
//             if (depthCm != null) ...[
//               const SizedBox(height: 8),
//               Row(
//                 children: [
//                   Icon(Icons.height, color: Colors.grey[600], size: 20),
//                   const SizedBox(width: 8),
//                   Text(
//                     'Depth: ${depthCm} cm',
//                     style: Theme.of(context).textTheme.bodyMedium,
//                   ),
//                 ],
//               ),
//             ],
            
//             if (note != null && note.isNotEmpty) ...[
//               const SizedBox(height: 8),
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Icon(Icons.note, color: Colors.grey[600], size: 20),
//                   const SizedBox(width: 8),
//                   Expanded(
//                     child: Text(
//                       note,
//                       style: Theme.of(context).textTheme.bodyMedium,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
            
//             if (photoUrls.isNotEmpty) ...[
//               const SizedBox(height: 8),
//               Row(
//                 children: [
//                   Icon(Icons.photo_library, color: Colors.grey[600], size: 20),
//                   const SizedBox(width: 8),
//                   Text(
//                     '${photoUrls.length} photo${photoUrls.length == 1 ? '' : 's'}',
//                     style: Theme.of(context).textTheme.bodyMedium,
//                   ),
//                 ],
//               ),
//             ],
            
//             const SizedBox(height: 16),
            
//             // Timestamps
//             Row(
//               children: [
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Created',
//                         style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                           color: Colors.grey[600],
//                         ),
//                       ),
//                       Text(
//                         DateFormat('MMM dd, HH:mm').format(createdAt),
//                         style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.end,
//                     children: [
//                       Text(
//                         'Expires',
//                         style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                           color: Colors.grey[600],
//                         ),
//                       ),
//                       Text(
//                         DateFormat('MMM dd, HH:mm').format(expiresAt),
//                         style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
            
//             const SizedBox(height: 16),
            
//             // Actions
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 if (status == 'active') ...[
//                   Expanded(
//                     child: OutlinedButton.icon(
//                       onPressed: () => _updateReportStatus(report['id'], 'resolved'),
//                       icon: const Icon(Icons.check_circle, size: 18),
//                       label: const Text('Mark Resolved'),
//                       style: OutlinedButton.styleFrom(
//                         foregroundColor: Colors.green,
//                         side: const BorderSide(color: Colors.green),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                 ],
//                 Expanded(
//                   child: OutlinedButton.icon(
//                     onPressed: () => _showDeleteDialog(report['id']),
//                     icon: const Icon(Icons.delete, size: 18),
//                     label: const Text('Delete'),
//                     style: OutlinedButton.styleFrom(
//                       foregroundColor: Colors.red,
//                       side: const BorderSide(color: Colors.red),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Future<void> _updateReportStatus(String reportId, String newStatus) async {
//     try {
//       final success = await ref.read(userProvider.notifier).updateReportStatus(reportId, newStatus);
      
//       if (success) {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text('Report marked as $newStatus'),
//               backgroundColor: Colors.green,
//             ),
//           );
//           // Refresh the data
//           ref.invalidate(userReportsProvider);
//           ref.invalidate(userReportStatsProvider);
//         }
//       } else {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Failed to update report status'),
//               backgroundColor: Colors.red,
//             ),
//           );
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   Future<void> _showDeleteDialog(String reportId) async {
//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Delete Report'),
//         content: const Text(
//           'Are you sure you want to delete this flood report? This action cannot be undone.',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(false),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(true),
//             style: TextButton.styleFrom(foregroundColor: Colors.red),
//             child: const Text('Delete'),
//           ),
//         ],
//       ),
//     );

//     if (confirmed == true) {
//       try {
//         final success = await ref.read(userProvider.notifier).deleteReport(reportId);
        
//         if (success) {
//           if (mounted) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(
//                 content: Text('Report deleted successfully'),
//                 backgroundColor: Colors.green,
//               ),
//             );
//             // Refresh the data
//             ref.invalidate(userReportsProvider);
//             ref.invalidate(userReportStatsProvider);
//           }
//         } else {
//           if (mounted) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(
//                 content: Text('Failed to delete report'),
//                 backgroundColor: Colors.red,
//               ),
//             );
//           }
//         }
//       } catch (e) {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text('Error: $e'),
//               backgroundColor: Colors.red,
//             ),
//           );
//         }
//       }
//     }
//   }
// }
