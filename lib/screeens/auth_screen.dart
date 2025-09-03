import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_provider.dart';
import '../screeens/map_screen.dart';
import '../screeens/update_reminder_screen.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  bool _isLoading = true;
  bool _isSigningIn = false;

  @override
  void initState() {
    super.initState();
    // Check for existing session after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkExistingSession();
    });
  }

  Future<void> _checkExistingSession() async {
    try {
      // Wait a bit for the user provider to initialize
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Check if user is already signed in
      final currentUser = ref.read(userProvider);
      
      if (mounted) {
        if (currentUser != null) {
          // User is already signed in, go to map
          debugPrint('✅ AuthScreen: User already signed in: ${currentUser.id}');
          _navigateToMap();
        } else {
          // No existing session, show sign-in options
          debugPrint('ℹ️ AuthScreen: No existing session found');
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('❌ AuthScreen: Error checking session: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signInAnonymously() async {
    setState(() {
      _isSigningIn = true;
    });

    try {
      final userNotifier = ref.read(userProvider.notifier);
      final user = await userNotifier.signInAnonymously();
      
      if (user != null) {
        debugPrint('✅ AuthScreen: Anonymous sign-in successful: ${user.id}');
        _navigateToMap();
      } else {
        debugPrint('❌ AuthScreen: Anonymous sign-in failed');
        setState(() {
          _isSigningIn = false;
        });
        _showErrorSnackBar('Sign-in failed. Please try again.');
      }
    } catch (e) {
      debugPrint('❌ AuthScreen: Error during sign-in: $e');
      setState(() {
        _isSigningIn = false;
      });
      _showErrorSnackBar('Sign-in error: $e');
    }
  }

  void _navigateToMap() {
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MapScreen()),
      );
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Checking for existing session...',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1976D2),
              Color(0xFF1565C0),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Logo/Icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(60),
                  ),
                  child: const Icon(
                    Icons.location_on,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 32),
                
                // App Title
                const Text(
                  'Flood Marker',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                
                // App Description
                const Text(
                  'Report and track flood conditions in your area',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                
                // Sign In Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSigningIn ? null : _signInAnonymously,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF1976D2),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSigningIn
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFF1976D2),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Text('Signing in...'),
                            ],
                          )
                        : const Text(
                            'Continue Anonymously',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Info Text
                const Text(
                  'Your data will be saved locally and anonymously',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white60,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                
                // // Skip to Update Reminder
                // TextButton(
                //   onPressed: () {
                //     Navigator.of(context).pushReplacement(
                //       MaterialPageRoute(
                //         builder: (context) => const UpdateReminderScreen(),
                //       ),
                //     );
                //   },
                //   child: const Text(
                //     'Skip to App',
                //     style: TextStyle(
                //       color: Colors.white70,
                //       fontSize: 14,
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
