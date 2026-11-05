import 'package:backloggr/core/constants.dart';
import 'package:backloggr/data/models/backlog_item.dart';
import 'package:backloggr/data/providers/backlog_notifier.dart';
import 'package:backloggr/ui/widgets/game_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:provider/provider.dart';

class BacklogScreen extends StatefulWidget {
  const BacklogScreen({super.key});

  @override
  State<BacklogScreen> createState() => _BacklogScreenState();
}

class _BacklogScreenState extends State<BacklogScreen> {
  @override
  void initState() {
    super.initState();
    // Trigger initial load post-frame if items are empty
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<BacklogProvider>();
      if (provider.items.isEmpty && !provider.isLoading) {
        provider.loadBacklog();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch BacklogProvider for reactive updates
    final backlogProvider = context.watch<BacklogProvider>();
    final List<BacklogItem> games = backlogProvider.items;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
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
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => context.read<BacklogProvider>().loadBacklog(),
                child: backlogProvider.isLoading && games.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : games.isEmpty
                    ? LayoutBuilder(
                        builder: (context, constraints) {
                          return SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: constraints.maxHeight,
                              ),
                              child: const Center(
                                child: Text(
                                  "No games found.",
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      )
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          final crossAxisCount =
                              context.isAtLeast(Breakpoint.md) ? 5 : 3;

                          return GridView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 8),
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
                                  key: ValueKey(game.id ?? game.gameId),
                                  title: game.gameTitle,
                                  imageUrl: game.coverUrl ?? '',
                                  onTap: () async {
                                    // Navigate to detail screen and refresh if modifications were made
                                    final result = await context.push(
                                      '/detail',
                                      extra: {'id': game.gameId.toString()},
                                    );

                                    if (result == true && context.mounted) {
                                      context
                                          .read<BacklogProvider>()
                                          .loadBacklog();
                                    }
                                  },
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
