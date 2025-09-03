import 'package:flood_marker/screeens/map_screen.dart';
import 'package:flood_marker/screeens/update_reminder_screen.dart';
import 'package:flood_marker/screeens/auth_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io' show Platform;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Platform-specific Supabase URLs
  String supabaseUrl;
  if (Platform.isIOS) {
    supabaseUrl = 'http://127.0.0.1:54321'; // iOS simulator
  } else if (Platform.isAndroid) {
    supabaseUrl = 'http://10.0.2.2:54321'; // Android emulator
  } else {
    supabaseUrl = 'http://127.0.0.1:54321'; // Default fallback
  }
  
  // Initialize Supabase with platform-specific URL
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0', // Local anon key
  );
  
  runApp(
  const  ProviderScope(
      overrides: [],
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
      home: const AuthScreen(),
      routes: {
        '/map': (context) => const MapScreen(),
        '/auth': (context) => const AuthScreen(),
        // '/update-reminder': (context) => const UpdateReminderScreen(),
      },
    );
  }
}

