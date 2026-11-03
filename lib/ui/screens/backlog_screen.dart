import 'package:backloggr/core/constants.dart';
import 'package:backloggr/data/models/backlog_item.dart';
import 'package:backloggr/data/services/supabase_service.dart';
import 'package:backloggr/ui/widgets/game_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BacklogScreen extends StatefulWidget {
  const BacklogScreen({super.key});

  @override
  State<BacklogScreen> createState() => _BacklogScreenState();
}

class _BacklogScreenState extends State<BacklogScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "BACKLOG",
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          centerTitle: true,
          backgroundColor: AppColors.scaffoldBackground,
          scrolledUnderElevation: 0.0,
        ),
        body: Column(
          children: [
            Expanded(
              child: FutureBuilder<List<BacklogItem>>(
                // Pastikan method ini dipanggil sekali, bukan langsung instantiate di build
                future: SupabaseService().fetchBacklog(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (snapshot.hasData) {
                    // snapshot.data LANGSUNG berupa List<BacklogItem>
                    final List<BacklogItem> games = snapshot.data!;

                    if (games.isEmpty) {
                      return const Center(child: Text("No games found."));
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
                          itemCount: games.length,
                          itemBuilder: (context, index) {
                            final game = games[index];

                            return Material(
                              color: Colors.transparent,
                              child: GameCard(
                                title: game.gameTitle,
                                imageUrl: game.coverUrl!,
                                onTap: () {
                                  context.push(
                                    '/detail',
                                    extra: {'id': game.gameId},
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
    );
  }
}
