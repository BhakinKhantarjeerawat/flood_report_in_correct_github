import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/anonymous_user.dart';

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
}
 

/// Provider instance for user management
final userProvider = StateNotifierProvider<UserNotifier, AnonymousUser?>((ref) {
  return UserNotifier();
});



