import 'package:backloggr/core/constants.dart';
import 'package:backloggr/data/models/game_model.dart';
import 'package:backloggr/data/services/cheapshark_api_service.dart';
import 'package:backloggr/ui/widgets/game_card.dart';
import 'package:backloggr/ui/widgets/game_detail_modal.dart';
import 'package:flutter/material.dart';
import 'package:exui/exui.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<GameModel> _games = [];
  int _currentPage = 0;
  bool _isLoading = false;
  bool _hasMore = true;
  String _currentQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchNextPage();

    // Attach scroll listener to trigger pagination near bottom
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isLoading &&
          _hasMore) {
        _fetchNextPage();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// Fetches the next page of games or search results
  Future<void> _fetchNextPage() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      List<GameModel> newGames = [];

      if (_currentQuery.isEmpty) {
        // Paged catalog fetching from /api/1.0/deals
        newGames = await CheapSharkApiService().fetchDeals(
          pageNumber: _currentPage,
          pageSize: 20,
        );
      } else {
        // Global search endpoint (/api/1.0/games doesn't support pagination)
        if (_currentPage == 0) {
          newGames = await CheapSharkApiService().searchGames(_currentQuery);
        }
        _hasMore = false; // Search endpoint returns all results at once
      }

      if (mounted) {
        setState(() {
          _currentPage++;
          _games.addAll(newGames);
          if (newGames.isEmpty || _currentQuery.isNotEmpty) {
            _hasMore = false;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading games: $e'),
            backgroundColor: AppColors.steamDiscountRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onSearchSubmitted() {
    FocusScope.of(context).unfocus();
    final query = _searchController.text.trim();

    setState(() {
      _currentQuery = query;
      _games.clear();
      _currentPage = 0;
      _hasMore = true;
    });

    _fetchNextPage();
  }

  void _clearSearchQuery() {
    _searchController.clear();
    _onSearchSubmitted();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "CATALOG",
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          centerTitle: true,
          backgroundColor: AppColors.scaffoldBackground,
          scrolledUnderElevation: 0.0,
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              // Search Input Field
              TextField(
                controller: _searchController,
                onEditingComplete: _onSearchSubmitted,
                onChanged: (_) => setState(() {}),
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  isDense: true,
                  filled: true,
                  fillColor: AppColors.gray300,
                  prefixIcon: const Icon(Icons.search),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 40,
                            minHeight: 40,
                          ),
                          onPressed: _clearSearchQuery,
                          icon: const Icon(Icons.clear, size: 18),
                        )
                      : null,
                  suffixIconConstraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: const TextStyle(color: AppColors.gray950),
              ).paddingAll(16),

              // GridView with Infinite Scroll
              Expanded(
                child: _games.isEmpty && _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _games.isEmpty
                    ? const Center(child: Text("No games found."))
                    : GridView.builder(
                        controller: _scrollController,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              childAspectRatio: 2 / 3,
                            ),
                        itemCount: _games.length + (_hasMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          // Render loading indicator item at the bottom of grid
                          if (index == _games.length) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          final deal = _games[index];

                          return Material(
                            color: Colors.transparent,
                            child: GameCard(
                              title: deal.title,
                              imageUrl: deal.verticalCoverUrl,
                              onTap: () {
                                showGameDetailModal(
                                  context: context,
                                  gameId: deal.gameID,
                                  title: deal.title,
                                  coverUrl: deal.verticalCoverUrl,
                                  capsuleUrl: deal.capsuleUrl,
                                );
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
