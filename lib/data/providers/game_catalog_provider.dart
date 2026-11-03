import 'package:backloggr/data/models/game_model.dart';
import 'package:flutter/material.dart';
import '../services/cheapshark_api_service.dart';

enum ViewState { initial, loading, success, empty, error }

class GameCatalogProvider extends ChangeNotifier {
  final CheapSharkApiService _apiService = CheapSharkApiService();

  ViewState _state = ViewState.initial;
  List<DealModel> _games = [];
  String _errorMessage = '';

  ViewState get state => _state;
  List<DealModel> get games => _games;
  String get errorMessage => _errorMessage;

  Future<void> loadCatalog({String? query}) async {
    _state = ViewState.loading;
    notifyListeners();

    try {
      if (query != null && query.trim().isNotEmpty) {
        _games = await _apiService.searchGames(query);
      } else {
        _games = await _apiService.fetchDeals(pageSize: 24);
      }

      if (_games.isEmpty) {
        _state = ViewState.empty;
      } else {
        _state = ViewState.success;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _state = ViewState.error;
    } finally {
      notifyListeners();
    }
  }
}
