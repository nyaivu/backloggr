import 'dart:convert';
import 'package:backloggr/data/models/game_model.dart';
import 'package:http/http.dart' as http;

class CheapSharkApiService {
  static const String _baseUrl = 'www.cheapshark.com';
  static const String _dealsEndpoint = '/api/1.0/deals';
  static const String _gamesEndpoint = '/api/1.0/games';

  final http.Client _client;

  CheapSharkApiService({http.Client? client})
    : _client = client ?? http.Client();

  /// Fetches a list of active game deals for general catalog browsing.
  ///
  /// Supports pagination ([pageNumber], [pageSize]) and optional filtering [title].
  Future<List<DealModel>> fetchDeals({
    String? title,
    int pageSize = 20,
    int pageNumber = 0,
  }) async {
    final queryParams = <String, String>{
      'pageSize': pageSize.toString(),
      'pageNumber': pageNumber.toString(),
      'storeID': "1",
    };

    if (title != null && title.trim().isNotEmpty) {
      queryParams['title'] = title.trim();
    }

    final uri = Uri.https(_baseUrl, _dealsEndpoint, queryParams);

    try {
      final response = await _client
          .get(uri)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => DealModel.fromDealJson(json)).toList();
      } else {
        throw Exception('Server returned status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error while connecting to CheapShark API: $e');
    }
  }

  /// Global title search via `/api/1.0/games`.
  ///
  /// Searches CheapShark's complete database even if the game currently has no active deal.
  Future<List<DealModel>> searchGames(String titleQuery) async {
    if (titleQuery.trim().isEmpty) return [];

    final uri = Uri.https(_baseUrl, _gamesEndpoint, {
      'title': titleQuery.trim(),
    });

    try {
      final response = await _client
          .get(uri)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList
            .map((json) => DealModel.fromGameSearchJson(json))
            .toList();
      } else {
        throw Exception('Server returned status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error while searching CheapShark API: $e');
    }
  }
}
