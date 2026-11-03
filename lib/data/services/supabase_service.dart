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

  // Insert Item
  Future<void> addToBacklog(BacklogItem item) async {
    final data = item.toJson();
    data['user_id'] = _currentUserId; // Bind authenticated user's UUID

    await _supabase.from('user_game_backlog').insert(data);
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
