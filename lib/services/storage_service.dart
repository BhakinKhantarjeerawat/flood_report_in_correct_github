import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../models/flood.dart';

/// Simple storage service using SharedPreferences for development and testing
class StorageService {
  static const String _floodReportsKey = 'flood_reports';
  
  /// Save a single flood report to local storage
  Future<bool> saveFloodReport(Flood flood) async {
    try {
      debugPrint('💾 StorageService: Starting save for report ${flood.id}');
      final prefs = await SharedPreferences.getInstance();
      debugPrint('💾 StorageService: Got SharedPreferences instance');
      
      // Get existing reports
      List<Flood> existingReports = await loadFloodReports();
      debugPrint('💾 StorageService: Loaded ${existingReports.length} existing reports');
      
      // Check if report already exists
      int existingIndex = existingReports.indexWhere((report) => report.id == flood.id);
      if (existingIndex != -1) {
        // Update existing report
        existingReports[existingIndex] = flood;
        debugPrint('💾 StorageService: Updated existing report ${flood.id}');
      } else {
        // Add new report
        existingReports.add(flood);
        debugPrint('💾 StorageService: Added new report, total now: ${existingReports.length}');
      }
      
      // Convert to JSON and save
      List<String> jsonList = existingReports.map((report) => jsonEncode(report.toMap())).toList();
      debugPrint('💾 StorageService: Converted to JSON, ${jsonList.length} items');
      
      bool result = await prefs.setStringList(_floodReportsKey, jsonList);
      debugPrint('💾 StorageService: Save operation result: $result');
      
      // Verify the save worked
      List<String>? savedData = prefs.getStringList(_floodReportsKey);
      debugPrint('💾 StorageService: Verification - saved data count: ${savedData?.length ?? 0}');
      
      return result;
      
    } catch (e) {
      debugPrint('❌ StorageService: Error saving flood report: $e');
      return false;
    }
  }
  
  /// Load all saved flood reports from local storage
  Future<List<Flood>> loadFloodReports() async {
    try {
      debugPrint('💾 StorageService: Starting to load flood reports');
      final prefs = await SharedPreferences.getInstance();
      debugPrint('💾 StorageService: Got SharedPreferences instance for loading');
      
      // Get saved JSON strings
      List<String>? jsonList = prefs.getStringList(_floodReportsKey);
      debugPrint('💾 StorageService: Raw JSON data count: ${jsonList?.length ?? 0}');
      
      if (jsonList == null || jsonList.isEmpty) {
        debugPrint('💾 StorageService: No saved data found');
        return [];
      }
      
      // Convert JSON back to Flood objects
      List<Flood> reports = [];
      for (int i = 0; i < jsonList.length; i++) {
        try {
          String jsonString = jsonList[i];
          debugPrint('💾 StorageService: Parsing JSON item $i: ${jsonString.substring(0, jsonString.length > 50 ? 50 : jsonString.length)}...');
          
          Map<String, dynamic> jsonMap = jsonDecode(jsonString);
          Flood report = Flood.fromMap(jsonMap);
          reports.add(report);
          debugPrint('💾 StorageService: Successfully parsed report ${report.id}');
        } catch (e) {
          debugPrint('⚠️ StorageService: Error parsing flood report $i: $e');
          // Continue with other reports
        }
      }
      
      debugPrint('💾 StorageService: Successfully loaded ${reports.length} reports');
      return reports;
      
    } catch (e) {
      debugPrint('❌ StorageService: Error loading flood reports: $e');
      return [];
    }
  }
  
  /// Clear all saved flood reports (for testing)
  Future<bool> clearAllReports() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_floodReportsKey);
    } catch (e) {
      print('❌ Error clearing reports: $e');
      return false;
    }
  }
}
