// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import '../models/flood.dart';
// import '../config/app_config.dart';

// /// Provider for managing flood reports from Supabase
// class FloodReportsNotifier extends StateNotifier<AsyncValue<List<Flood>>> {
//   FloodReportsNotifier() : super(const AsyncValue.loading());

//   final SupabaseClient _supabase = Supabase.instance.client;

//   /// Fetch all flood reports from Supabase
//   Future<void> fetchAllReports() async {
//     try {
//       AppConfig.infoLog('🔄 FloodReportsProvider: Fetching all flood reports...');
      
//       state = const AsyncValue.loading();
      
//       final response = await _supabase
//           .from('flood_reports')
//           .select('*')
//           .order('created_at', ascending: false);
      
//       if (response != null) {
//         final List<Flood> reports = response.map<Flood>((data) {
//           return Flood.fromMap(data);
//         }).toList();
        
//         AppConfig.infoLog('✅ FloodReportsProvider: Fetched ${reports.length} reports');
//         state = AsyncValue.data(reports);
//       } else {
//         AppConfig.errorLog('❌ FloodReportsProvider: No response from Supabase');
//         state = const AsyncValue.data([]);
//       }
//     } catch (e) {
//       AppConfig.errorLog('❌ FloodReportsProvider: Error fetching reports: $e');
//       if (e is PostgrestException) {
//         AppConfig.errorLog('❌ FloodReportsProvider: PostgrestException details: ${e.message}');
//         AppConfig.errorLog('❌ FloodReportsProvider: PostgrestException code: ${e.code}');
//       }
//       state = AsyncValue.error(e, StackTrace.current);
//     }
//   }

//   /// Refresh the reports data
//   Future<void> refresh() async {
//     await fetchAllReports();
//   }

//   /// Get reports by status
//   List<Flood> getReportsByStatus(String status) {
//     final reports = state.value ?? [];
//     return reports.where((report) => report.status == status).toList();
//   }

//   /// Get active reports only
//   List<Flood> getActiveReports() {
//     return getReportsByStatus('active');
//   }

//   /// Get resolved reports only
//   List<Flood> getResolvedReports() {
//     return getReportsByStatus('resolved');
//   }

//   /// Get total report count
//   int get totalReports => state.value?.length ?? 0;

//   /// Get active report count
//   int get activeReports => getActiveReports().length;

//   /// Get resolved report count
//   int get resolvedReports => getResolvedReports().length;
// }

// /// Provider instance for flood reports
// final floodReportsProvider = StateNotifierProvider<FloodReportsNotifier, AsyncValue<List<Flood>>>(
//   (ref) => FloodReportsNotifier(),
// );

// /// Provider for active flood reports only
// final activeFloodReportsProvider = Provider<List<Flood>>((ref) {
//   final reportsAsync = ref.watch(floodReportsProvider);
//   return reportsAsync.when(
//     data: (reports) => reports.where((report) => report.status == 'active').toList(),
//     loading: () => [],
//     error: (_, __) => [],
//   );
// });

// /// Provider for resolved flood reports only
// final resolvedFloodReportsProvider = Provider<List<Flood>>((ref) {
//   final reportsAsync = ref.watch(floodReportsProvider);
//   return reportsAsync.when(
//     data: (reports) => reports.where((report) => report.status == 'resolved').toList(),
//     loading: () => [],
//     error: (_, __) => [],
//   );
// });
