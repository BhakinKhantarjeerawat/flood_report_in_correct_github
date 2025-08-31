import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/anonymous_user.dart';
import '../config/app_config.dart';

/// Provider for managing anonymous user authentication state
class UserNotifier extends StateNotifier<AnonymousUser?> {
  UserNotifier() : super(null) {
    _initializeUser();
  }

  /// Initialize user from existing session
  Future<void> _initializeUser() async {
    try {
      final supabase = Supabase.instance.client;
      final session = supabase.auth.currentSession;
      
      if (session != null && session.user != null) {
        final user = AnonymousUser.fromSupabase(session.user!.toJson());
        state = user;
        // AppConfig.infoLog('🔄 UserProvider: Initialized with existing user: ${user.id}');
      } else {
        // AppConfig.infoLog('🔄 UserProvider: No existing session found');
      }
    } catch (e) {
      // AppConfig.errorLog('❌ UserProvider: Error initializing user: $e');
    }
  }

  /// Sign in anonymously
  Future<AnonymousUser?> signInAnonymously() async {
    try {
      // AppConfig.infoLog('🔄 UserProvider: Starting anonymous sign-in...');
      
      final supabase = Supabase.instance.client;
      final response = await supabase.auth.signInAnonymously();
      
      if (response.user != null) {
        final user = AnonymousUser.fromSupabase(response.user!.toJson());
        state = user;
        // AppConfig.infoLog('✅ UserProvider: Anonymous sign-in successful: ${user.id}');
        return user;
      } else {
        // AppConfig.errorLog('❌ UserProvider: Anonymous sign-in failed - no user returned');
        return null;
      }
    } catch (e) {
      // AppConfig.errorLog('❌ UserProvider: Error during anonymous sign-in: $e');
      return null;
    }
  }

  /// Sign out user
  Future<void> signOut() async {
    try {
      // AppConfig.infoLog('🔄 UserProvider: Starting sign-out...');
      
      final supabase = Supabase.instance.client;
      await supabase.auth.signOut();
      
      state = null;
      // AppConfig.infoLog('✅ UserProvider: Sign-out successful');
    } catch (e) {
      // AppConfig.errorLog('❌ UserProvider: Error during sign-out: $e');
    }
  }

  /// Get current user
  AnonymousUser? get currentUser => state;

  /// Check if user is signed in
  bool get isSignedIn => state != null;

  /// Get user ID (safe access)
  String? get userId => state?.id;

  /// Update user display name
  Future<void> updateDisplayName(String newName) async {
    if (state != null) {
      final updatedUser = state!.copyWith(displayName: newName);
      state = updatedUser;
      // AppConfig.infoLog('✅ UserProvider: Display name updated to: $newName');
    }
  }

  /// Refresh user data from Supabase
  Future<void> refreshUser() async {
    try {
      final supabase = Supabase.instance.client;
      final session = supabase.auth.currentSession;
      
      if (session?.user != null) {
        final user = AnonymousUser.fromSupabase(session!.user!.toJson());
        state = user;
        // AppConfig.infoLog('✅ UserProvider: User data refreshed: ${user.id}');
      }
    } catch (e) {
      // AppConfig.errorLog('❌ UserProvider: Error refreshing user: $e');
    }
  }

  /// Get all flood reports submitted by the current user
  Future<List<Map<String, dynamic>>> getUserReports() async {
    try {
      if (state == null) {
        // AppConfig.errorLog('❌ UserProvider: No user signed in');
        return [];
      }

      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('flood_reports')
          .select('*')
          .eq('user_id', state!.id)
          .order('created_at', ascending: false);

      // AppConfig.infoLog('✅ UserProvider: Fetched ${response.length} user reports');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      // AppConfig.errorLog('❌ UserProvider: Error fetching user reports: $e');
      return [];
    }
  }

  /// Update a flood report status
  Future<bool> updateReportStatus(String reportId, String newStatus) async {
    try {
      if (state == null) {
        // AppConfig.errorLog('❌ UserProvider: No user signed in');
        return false;
      }

      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('flood_reports')
          .update({'status': newStatus, 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', reportId)
          .eq('user_id', state!.id); // Ensure user owns the report

      // AppConfig.infoLog('✅ UserProvider: Report status updated to: $newStatus');
      return true;
    } catch (e) {
      // AppConfig.errorLog('❌ UserProvider: Error updating report status: $e');
      return false;
    }
  }

  /// Delete a flood report (only if user owns it)
  Future<bool> deleteReport(String reportId) async {
    try {
      if (state == null) {
        // AppConfig.errorLog('❌ UserProvider: No user signed in');
        return false;
      }

      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('flood_reports')
          .delete()
          .eq('id', reportId)
          .eq('user_id', state!.id); // Ensure user owns the report

      // AppConfig.infoLog('✅ UserProvider: Report deleted successfully');
      return true;
    } catch (e) {
      // AppConfig.errorLog('❌ UserProvider: Error deleting report: $e');
      return false;
    }
  }

  /// Get report statistics for the current user
  Future<Map<String, dynamic>> getUserReportStats() async {
    try {
      if (state == null) {
        // AppConfig.errorLog('❌ UserProvider: No user signed in');
        return {};
      }

      final supabase = Supabase.instance.client;
      
      // Get all reports for the user
      final allReports = await supabase
          .from('flood_reports')
          .select('id, status, severity')
          .eq('user_id', state!.id);

      final totalReports = allReports.length;
      final activeReports = allReports.where((report) => report['status'] == 'active').length;
      
      // Count by severity
      final severityCounts = <String, int>{};
      for (final report in allReports) {
        final severity = report['severity'] as String;
        severityCounts[severity] = (severityCounts[severity] ?? 0) + 1;
      }

      final stats = {
        'total_reports': totalReports,
        'active_reports': activeReports,
        'resolved_reports': totalReports - activeReports,
        'severity_breakdown': severityCounts,
      };

      // AppConfig.infoLog('✅ UserProvider: Fetched user report stats: $stats');
      return stats;
    } catch (e) {
      // AppConfig.errorLog('❌ UserProvider: Error fetching user stats: $e');
      return {};
    }
  }
}

/// Provider instance for user management
final userProvider = StateNotifierProvider<UserNotifier, AnonymousUser?>((ref) {
  return UserNotifier();
});

/// Provider for current user ID (convenience access)
final userIdProvider = Provider<String?>((ref) {
  return ref.watch(userProvider)?.id;
});

/// Provider for signed-in status (convenience access)
final isSignedInProvider = Provider<bool>((ref) {
  return ref.watch(userProvider) != null;
});

// Provider for user's flood reports
final userReportsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final userNotifier = ref.read(userProvider.notifier);
  return await userNotifier.getUserReports();
});

// Provider for user's report statistics
final userReportStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final userNotifier = ref.read(userProvider.notifier);
  return await userNotifier.getUserReportStats();
});
