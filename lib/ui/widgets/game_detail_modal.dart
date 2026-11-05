import 'package:backloggr/core/constants.dart';
import 'package:backloggr/data/services/supabase_service.dart';
import 'package:flutter/material.dart';

void showGameDetailModal({
  required BuildContext context,
  required String gameId,
  required String title,
  required String coverUrl,
  required String capsuleUrl,
}) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'GameDetails',
    barrierColor: Colors.black.withOpacity(0.7),
    transitionDuration: const Duration(milliseconds: 250),
    pageBuilder: (context, anim1, anim2) => const SizedBox.shrink(),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curve = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutBack,
      );

      return ScaleTransition(
        scale: curve,
        child: FadeTransition(
          opacity: animation,
          child: _GameDetailModalContent(
            gameId: gameId,
            title: title,
            coverUrl: coverUrl,
            capsuleUrl: capsuleUrl,
          ),
        ),
      );
    },
  );
}

class _GameDetailModalContent extends StatefulWidget {
  final String gameId;
  final String title;
  final String coverUrl;
  final String capsuleUrl;

  const _GameDetailModalContent({
    required this.gameId,
    required this.title,
    required this.coverUrl,
    required this.capsuleUrl,
  });

  @override
  State<_GameDetailModalContent> createState() =>
      _GameDetailModalContentState();
}

class _GameDetailModalContentState extends State<_GameDetailModalContent> {
  bool _isLoading = false;

  Future<void> _handleAddToBacklog() async {
    setState(() => _isLoading = true);
    try {
      await SupabaseService().addToBacklog(
        gameId: widget.gameId,
        title: widget.title,
        coverUrl: widget.coverUrl,
        capsuleUrl: widget.capsuleUrl,
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.title} added to your backlog!'),
            backgroundColor: AppColors.steamGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.steamDiscountRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          color: AppColors.gray900,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header Image with Title Banner & Close Button
              Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      widget.capsuleUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: AppColors.gray800,
                        child: const Icon(
                          Icons.sports_esports,
                          color: Colors.white54,
                          size: 48,
                        ),
                      ),
                    ),
                  ),

                  // Dark Gradient Overlay for Title
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withAlpha(60),
                            Colors.transparent,
                            Colors.black.withAlpha(80),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Game Title
                  Positioned(
                    left: 16,
                    bottom: 12,
                    right: 48,
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // Close Button (X)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              ),

              // 2. Action Area & Steam Blue Panel
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: AppColors.gray800,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.steamBlue,
                        foregroundColor: AppColors.gray950,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      onPressed: _isLoading ? null : _handleAddToBacklog,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.add_to_photos),
                      label: Text(
                        _isLoading ? 'Adding...' : 'ADD TO BACKLOG',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
