import 'package:flutter/material.dart';
import 'package:backloggr/data/models/backlog_item.dart';
import 'package:backloggr/data/services/supabase_service.dart';

class BacklogProvider extends ChangeNotifier {
  List<BacklogItem> _items = [];
  bool _isLoading = false;

  List<BacklogItem> get items => _items;
  bool get isLoading => _isLoading;

  Future<void> loadBacklog() async {
    _isLoading = true;
    notifyListeners();
    try {
      _items = await SupabaseService().fetchBacklog();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Optimistic Add
  Future<void> addItem(BacklogItem item) async {
    _items.insert(0, item);
    notifyListeners();
    try {
      await SupabaseService().addToBacklog(
        gameId: item.gameId.toString(),
        title: item.gameTitle,
        coverUrl: item.coverUrl ?? '',
        capsuleUrl: item.capsuleUrl ?? '',
      );
    } catch (e) {
      _items.removeWhere((i) => i.gameId == item.gameId);
      notifyListeners();
      rethrow;
    }
  }

  // Optimistic Update
  Future<void> updateItem(BacklogItem updatedItem) async {
    final index = _items.indexWhere((i) => i.id == updatedItem.id);
    if (index == -1) return;

    final oldItem = _items[index];
    _items[index] = updatedItem;
    notifyListeners();

    try {
      await SupabaseService().updateBacklogItem(updatedItem);
    } catch (e) {
      _items[index] = oldItem;
      notifyListeners();
      rethrow;
    }
  }

  // Optimistic Delete
  Future<void> deleteItem(int id) async {
    final index = _items.indexWhere((i) => i.id == id);
    if (index == -1) return;

    final removedItem = _items[index];

    // Remove immediately from UI
    _items.removeAt(index);
    notifyListeners();

    try {
      await SupabaseService().deleteBacklogItem(id);
    } catch (e) {
      // Rollback if Supabase deletion fails
      _items.insert(index, removedItem);
      notifyListeners();
      rethrow;
    }
  }
}
