// // import 'dart:convert';
// import 'package:flutter/foundation.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class UserActionService {
//   static const String _confirmedReportsKey = 'user_confirmed_reports';
//   static const String _flaggedReportsKey = 'user_flagged_reports';
  
//   /// Check if user has already confirmed a specific flood report
//   Future<bool> hasConfirmedReport(String reportId) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       List<String> confirmedIds = prefs.getStringList(_confirmedReportsKey) ?? [];
//       return confirmedIds.contains(reportId);
//     } catch (e) {
//       debugPrint('❌ UserActionService: Error checking confirmed status: $e');
//       return false;
//     }
//   }
  
//   /// Check if user has already flagged a specific flood report
//   Future<bool> hasFlaggedReport(String reportId) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       List<String> flaggedIds = prefs.getStringList(_flaggedReportsKey) ?? [];
//       return flaggedIds.contains(reportId);
//     } catch (e) {
//       debugPrint('❌ UserActionService: Error checking flagged status: $e');
//       return false;
//     }
//   }
  
//   /// Mark a flood report as confirmed by the user
//   Future<bool> markReportAsConfirmed(String reportId) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       List<String> confirmedIds = prefs.getStringList(_confirmedReportsKey) ?? [];
      
//       // Check if already confirmed
//       if (confirmedIds.contains(reportId)) {
//         debugPrint('⚠️ UserActionService: Report $reportId already confirmed by user');
//         return false;
//       }
      
//       // Add to confirmed list
//       confirmedIds.add(reportId);
//       bool saved = await prefs.setStringList(_confirmedReportsKey, confirmedIds);
      
//       if (saved) {
//         debugPrint('✅ UserActionService: Marked report $reportId as confirmed');
//       } else {
//         debugPrint('❌ UserActionService: Failed to save confirmed status');
//       }
      
//       return saved;
//     } catch (e) {
//       debugPrint('❌ UserActionService: Error marking report as confirmed: $e');
//       return false;
//     }
//   }
  
//   /// Mark a flood report as flagged by the user
//   Future<bool> markReportAsFlagged(String reportId) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       List<String> flaggedIds = prefs.getStringList(_flaggedReportsKey) ?? [];
      
//       // Check if already flagged
//       if (flaggedIds.contains(reportId)) {
//         debugPrint('⚠️ UserActionService: Report $reportId already flagged by user');
//         return false;
//       }
      
//       // Add to flagged list
//       flaggedIds.add(reportId);
//       bool saved = await prefs.setStringList(_flaggedReportsKey, flaggedIds);
      
//       if (saved) {
//         debugPrint('✅ UserActionService: Marked report $reportId as flagged');
//       } else {
//         debugPrint('❌ UserActionService: Failed to save flagged status');
//       }
      
//       return saved;
//     } catch (e) {
//       debugPrint('❌ UserActionService: Error marking report as flagged: $e');
//       return false;
//     }
//   }
  
//   /// Get all reports confirmed by the user
//   Future<List<String>> getConfirmedReportIds() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       return prefs.getStringList(_confirmedReportsKey) ?? [];
//     } catch (e) {
//       debugPrint('❌ UserActionService: Error getting confirmed reports: $e');
//       return [];
//     }
//   }
  
//   /// Get all reports flagged by the user
//   Future<List<String>> getFlaggedReportIds() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       return prefs.getStringList(_flaggedReportsKey) ?? [];
//     } catch (e) {
//       debugPrint('❌ UserActionService: Error getting flagged reports: $e');
//       return [];
//     }
//   }
  
//   /// Clear all user actions (useful for testing or user logout)
//   Future<bool> clearAllUserActions() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       bool confirmedCleared = await prefs.remove(_confirmedReportsKey);
//       bool flaggedCleared = await prefs.remove(_flaggedReportsKey);
      
//       debugPrint('🧹 UserActionService: Cleared all user actions');
//       return confirmedCleared && flaggedCleared;
//     } catch (e) {
//       debugPrint('❌ UserActionService: Error clearing user actions: $e');
//       return false;
//     }
//   }
// }
