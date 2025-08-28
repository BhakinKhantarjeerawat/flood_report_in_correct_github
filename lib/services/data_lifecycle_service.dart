import 'package:flutter/foundation.dart';
import '../models/flood.dart';
import 'storage_service.dart';

class DataLifecycleService {
  final StorageService _storageService = StorageService();
  
  /// Check if a flood report has expired
  bool isExpired(Flood flood) {
    final now = DateTime.now();
    return now.isAfter(flood.expiresAt);
  }
  
  /// Check if a flood report should be considered stale (older than 24 hours)
  bool isStale(Flood flood) {
    final now = DateTime.now();
    final staleThreshold = now.subtract(const Duration(hours: 24));
    return flood.createdAt.isBefore(staleThreshold);
  }
  
  /// Get the appropriate status for a flood report based on its lifecycle
  String getLifecycleStatus(Flood flood) {
    if (flood.status == 'resolved') {
      return 'resolved';
    }
    
    if (isExpired(flood)) {
      return 'expired';
    }
    
    if (isStale(flood)) {
      return 'stale';
    }
    
    return 'active';
  }
  
  /// Process all flood reports and update their lifecycle status
  Future<List<Flood>> processLifecycleStatuses(List<Flood> reports) async {
    List<Flood> updatedReports = [];
    bool hasChanges = false;
    
    for (Flood report in reports) {
      String newStatus = getLifecycleStatus(report);
      
      if (newStatus != report.status) {
        // Update the status
        Flood updatedReport = report.copyWith(status: newStatus);
        updatedReports.add(updatedReport);
        hasChanges = true;
        
        debugPrint('🔄 DataLifecycleService: Updated report ${report.id} status from ${report.status} to $newStatus');
      } else {
        updatedReports.add(report);
      }
    }
    
    // Save changes if any were made
    if (hasChanges) {
      await _saveUpdatedReports(updatedReports);
    }
    
    return updatedReports;
  }
  
  /// Clean up expired reports from storage
  Future<List<Flood>> cleanupExpiredReports(List<Flood> reports) async {
    List<Flood> activeReports = reports.where((report) => !isExpired(report)).toList();
    List<Flood> expiredReports = reports.where((report) => isExpired(report)).toList();
    
    if (expiredReports.isNotEmpty) {
      debugPrint('🧹 DataLifecycleService: Removing ${expiredReports.length} expired reports');
      
      // Save only active reports
      await _saveUpdatedReports(activeReports);
      
      // Log expired reports for debugging
      for (Flood expired in expiredReports) {
        debugPrint('🗑️ DataLifecycleService: Expired report ${expired.id} created at ${expired.createdAt}');
      }
    }
    
    return activeReports;
  }
  
  /// Get reports grouped by lifecycle status
  Map<String, List<Flood>> groupReportsByStatus(List<Flood> reports) {
    Map<String, List<Flood>> grouped = {
      'active': [],
      'resolved': [],
      'stale': [],
      'expired': [],
    };
    
    for (Flood report in reports) {
      String status = getLifecycleStatus(report);
      grouped[status]!.add(report);
    }
    
    return grouped;
  }
  
  /// Get summary statistics for reports
  Map<String, int> getReportStatistics(List<Flood> reports) {
    Map<String, List<Flood>> grouped = groupReportsByStatus(reports);
    
    return {
      'total': reports.length,
      'active': grouped['active']!.length,
      'resolved': grouped['resolved']!.length,
      'stale': grouped['stale']!.length,
      'expired': grouped['expired']!.length,
    };
  }
  
  /// Archive resolved reports (move them to a separate storage area)
  Future<bool> archiveResolvedReports(List<Flood> reports) async {
    try {
      List<Flood> resolvedReports = reports.where((report) => report.status == 'resolved').toList();
      
      if (resolvedReports.isEmpty) {
        return true;
      }
      
      // TODO: Implement archive storage (for now, just log)
      debugPrint('📦 DataLifecycleService: Archiving ${resolvedReports.length} resolved reports');
      
      for (Flood resolved in resolvedReports) {
        debugPrint('📦 DataLifecycleService: Archived report ${resolved.id} - ${resolved.severity} at ${resolved.createdAt}');
      }
      
      return true;
    } catch (e) {
      debugPrint('❌ DataLifecycleService: Error archiving resolved reports: $e');
      return false;
    }
  }
  
  /// Get time until expiration for a report
  Duration getTimeUntilExpiration(Flood flood) {
    final now = DateTime.now();
    if (now.isAfter(flood.expiresAt)) {
      return Duration.zero;
    }
    return flood.expiresAt.difference(now);
  }
  
  /// Get user-friendly expiration text
  String getExpirationText(Flood flood) {
    if (isExpired(flood)) {
      return 'Expired';
    }
    
    Duration timeLeft = getTimeUntilExpiration(flood);
    
    if (timeLeft.inMinutes < 60) {
      return 'Expires in ${timeLeft.inMinutes}m';
    } else if (timeLeft.inHours < 24) {
      return 'Expires in ${timeLeft.inHours}h';
    } else {
      return 'Expires in ${timeLeft.inDays}d';
    }
  }
  
  /// Save updated reports to storage
  Future<void> _saveUpdatedReports(List<Flood> reports) async {
    try {
      for (Flood report in reports) {
        await _storageService.saveFloodReport(report);
      }
      debugPrint('💾 DataLifecycleService: Saved ${reports.length} updated reports');
    } catch (e) {
      debugPrint('❌ DataLifecycleService: Error saving updated reports: $e');
    }
  }
}
