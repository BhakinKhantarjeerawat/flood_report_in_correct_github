import 'package:flood_marker/screeens/map_screen.dart';
import 'package:flood_marker/screeens/update_reminder_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables from .env file
  await dotenv.load(fileName: ".env");
  
  // Initialize Supabase
  // For local development, use the URLs from your supabase/config.toml
  // For production, replace with your actual Supabase project credentials
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? 'http://127.0.0.1:54321', // Local Supabase URL from config.toml
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0', // Default local anon key
  );
  
  runApp(
  const  ProviderScope(
      overrides: [
        // 🧪 PROVIDER OVERRIDE EXAMPLES:
        
        // 1. ✅ EASY START: Mock Map Controller for Testing & Debugging
        // mapControllerProvider.overrideWith((ref) => MockMapControllerNotifier()),
        
        // 2. Override with Custom Implementation
        // mapControllerProvider.overrideWith((ref) => CustomMapControllerNotifier()),
        
        // 3. Override with Different Data
        // floodDataProvider.overrideWith((ref) => TestFloodData()),
        
        // 4. Override Multiple Providers
        // locationProvider.overrideWith((ref) => MockLocationProvider()),
        
        // 5. Conditional Override Based on Environment
        // if (const bool.fromEnvironment('USE_MOCK_DATA')) {
        //   mapControllerProvider.overrideWith((ref) => MockMapControllerNotifier()),
        // }
      ],
      child:  MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const UpdateReminderScreen(),
      routes: {
        '/map': (context) => const MapScreen(),
      },
    );
  }
}

