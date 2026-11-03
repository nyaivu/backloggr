import 'package:flutter/material.dart';
import '../models/backlog_item.dart';
import '../services/supabase_service.dart';

enum ViewState { initial, loading, success, empty, error }

class BacklogProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  ViewState _state = ViewState.initial;
  List<BacklogItem> _backlog = [];
  String _errorMessage = '';

  ViewState get state => _state;
  List<BacklogItem> get backlog => _backlog;
  String get errorMessage => _errorMessage;

  Future<void> fetchBacklog() async {
    _state = ViewState.loading;
    notifyListeners();

    try {
      _backlog = await _supabaseService.fetchBacklog();
      _state = _backlog.isEmpty ? ViewState.empty : ViewState.success;
    } catch (e) {
      _errorMessage = e.toString();
      _state = ViewState.error;
    } finally {
      notifyListeners();
    }
  }

  Future<void> addGame(BacklogItem item) async {
    try {
      await _supabaseService.addToBacklog(item);
      await fetchBacklog();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateGame(BacklogItem item) async {
    try {
      await _supabaseService.updateBacklogItem(item);
      await fetchBacklog();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteGame(int id) async {
    try {
      await _supabaseService.deleteBacklogItem(id);
      await fetchBacklog();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}
