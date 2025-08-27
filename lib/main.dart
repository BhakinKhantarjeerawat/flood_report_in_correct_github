import 'package:flood_marker/screeens/map_screen.dart';
import 'package:flood_marker/screeens/update_reminder_screen.dart';
import 'package:flood_marker/providers/map_controller_provider.dart';
import 'package:flood_marker/providers/mock_map_controller_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  runApp(
    ProviderScope(
      overrides: const [
        // 🧪 PROVIDER OVERRIDE EXAMPLES:
        
        // 1. Override with Mock Controller for Testing
        // mapControllerProvider.overrideWith((ref) => MockMapControllerNotifier()),
        
        // 2. Override with Custom Implementation
        // mapControllerProvider.overrideWith((ref) => CustomMapControllerNotifier()),
        
        // 3. Override with Different Data
        // floodDataProvider.overrideWith((ref) => TestFloodData()),
        
        // 4. Override Multiple Providers
        // mapControllerProvider.overrideWith((ref) => MockMapControllerNotifier()),
        // locationProvider.overrideWith((ref) => MockLocationProvider()),
        
        // 5. Conditional Override Based on Environment
        // if (const bool.fromEnvironment('USE_MOCK_DATA')) {
        //   mapControllerProvider.overrideWith((ref) => MockMapControllerNotifier()),
        // }
      ],
      child: const MyApp(),
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

