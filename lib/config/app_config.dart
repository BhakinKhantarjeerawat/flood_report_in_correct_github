/// Application configuration for development and production
class AppConfig {
  // Development flags
  // static const bool useFakeData = false; // Set to true only for development/testing
  static const bool enableDebugLogs = true; // Enable/disable debug console logs
  
  // // Data source configuration
  // static const bool useLocalStorage = false; // Use local storage instead of Supabase
  // static const bool useMockServices = false; // Use mock services for testing
  
  // // Feature flags
  // static const bool enableUserReports = true; // Enable user report history
  // static const bool enableRealTimeUpdates = true; // Enable real-time Supabase updates
  
  // // Development helpers
  // static bool get isDevelopment => useFakeData || useLocalStorage || useMockServices;
  // static bool get isProduction => !isDevelopment;
  
  // Logging helpers
  static void debugLog(String message) {
    if (enableDebugLogs) {
      print('🔧 [DEBUG] $message');
    }
  }
  
  static void infoLog(String message) {
    print('ℹ️ [INFO] $message');
  }
  
  static void errorLog(String message) {
    print('❌ [ERROR] $message');
  }
}
