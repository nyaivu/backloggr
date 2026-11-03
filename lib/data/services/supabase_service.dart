import 'package:backloggr/data/models/backlog_item.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  String get _currentUserId {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('No authenticated user found.');
    return user.id;
  }

  // Fetch Backlog for Authenticated User
  Future<List<BacklogItem>> fetchBacklog() async {
    final response = await _supabase
        .from('user_game_backlog')
        .select()
        .eq('user_id', _currentUserId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => BacklogItem.fromJson(json))
        .toList();
  }

  // Fetch Backlog for Authenticated User
  Future<BacklogItem?> fetchBacklogByID(String id) async {
    final response = await _supabase
        .from('user_game_backlog')
        .select()
        .eq('user_id', _currentUserId)
        .eq('game_id', id)
        .maybeSingle(); // Returns null safely if no matching game is found

    if (response == null) return null;

    return BacklogItem.fromJson(response);
  }

  // Insert Item
  Future<void> addToBacklog({
    required String gameId,
    required String title,
    required String coverUrl,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User is not authenticated.');
    }

    await _supabase.from('user_game_backlog').insert({
      'user_id': user.id,
      'game_id': gameId,
      'game_title': title,
      'cover_url': coverUrl,
      'completion_status': 'Unfinished',
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // Update Item
  Future<void> updateBacklogItem(BacklogItem item) async {
    await _supabase
        .from('user_game_backlog')
        .update(item.toJson())
        .eq('id', item.id!)
        .eq('user_id', _currentUserId);
  }

  // Delete Item
  Future<void> deleteBacklogItem(int id) async {
    await _supabase
        .from('user_game_backlog')
        .delete()
        .eq('id', id)
        .eq('user_id', _currentUserId);
  }
}
