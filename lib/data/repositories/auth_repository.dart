import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final SupabaseClient _client = Supabase.instance.client;

  /// Gets the currently logged-in user. Returns null if not logged in.
  User? get currentUser => _client.auth.currentUser;

  /// Registers a new user with email and password
  Future<AuthResponse> registerUser({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signUp(email: email, password: password);
  }

  /// Logs in an existing user
  Future<AuthResponse> loginUser({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Logs out the current user
  Future<void> logout() async {
    await _client.auth.signOut();
  }
}
