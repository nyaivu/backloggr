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
  late Future<List<GameModel>> _futureQuery;

  @override
  void initState() {
    super.initState();
    // Initial load: Fetch default deals catalog
    _futureQuery = CheapSharkApiService().fetchDeals();
  }

  void _onSearchSubmitted() {
    FocusScope.of(context).unfocus(); // Close the keyboard
    final query = _searchController.text.trim();

    setState(() {
      if (query.isEmpty) {
        _futureQuery = CheapSharkApiService().fetchDeals();
      } else {
        // Replace with your actual service method for title search
        _futureQuery = CheapSharkApiService().searchGames(query);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
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
              TextField(
                controller: _searchController,
                onEditingComplete: _onSearchSubmitted,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.gray300,
                  icon: Icon(Icons.search),
                ),
                style: TextStyle(color: AppColors.gray950),
              ).paddingAll(16),

              Expanded(
                child: FutureBuilder<List<GameModel>>(
                  // Pastikan method ini dipanggil sekali, bukan langsung instantiate di build
                  future: _futureQuery,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (snapshot.hasData) {
                      // snapshot.data LANGSUNG berupa List<GameModel>
                      final List<GameModel> deals = snapshot.data!;

                      if (deals.isEmpty) {
                        return const Center(child: Text("No deals found."));
                      }

                      return LayoutBuilder(
                        builder: (context, constraints) {
                          final crossAxisCount = 3;
                          return GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: 2 / 3,
                                ),
                            itemCount: deals.length,
                            itemBuilder: (context, index) {
                              final deal = deals[index];

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
                                      imageUrl: deal.hdCoverUrl,
                                    );
                                  },
                                ),
                              );
                            },
                          );
                        },
                      );
                    }
                    return const Center(child: Text("Empty state"));
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
