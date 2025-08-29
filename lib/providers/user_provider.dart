import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/anonymous_user.dart';

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
        print('🔄 UserProvider: Initialized with existing user: ${user.id}');
      } else {
        print('🔄 UserProvider: No existing session found');
      }
    } catch (e) {
      print('❌ UserProvider: Error initializing user: $e');
    }
  }

  /// Sign in anonymously
  Future<AnonymousUser?> signInAnonymously() async {
    try {
      print('🔄 UserProvider: Starting anonymous sign-in...');
      
      final supabase = Supabase.instance.client;
      final response = await supabase.auth.signInAnonymously();
      
      if (response.user != null) {
        final user = AnonymousUser.fromSupabase(response.user!.toJson());
        state = user;
        print('✅ UserProvider: Anonymous sign-in successful: ${user.id}');
        return user;
      } else {
        print('❌ UserProvider: Anonymous sign-in failed - no user returned');
        return null;
      }
    } catch (e) {
      print('❌ UserProvider: Error during anonymous sign-in: $e');
      return null;
    }
  }

  /// Sign out user
  Future<void> signOut() async {
    try {
      print('🔄 UserProvider: Starting sign-out...');
      
      final supabase = Supabase.instance.client;
      await supabase.auth.signOut();
      
      state = null;
      print('✅ UserProvider: Sign-out successful');
    } catch (e) {
      print('❌ UserProvider: Error during sign-out: $e');
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
      print('✅ UserProvider: Display name updated to: $newName');
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
        print('✅ UserProvider: User data refreshed: ${user.id}');
      }
    } catch (e) {
      print('❌ UserProvider: Error refreshing user: $e');
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
