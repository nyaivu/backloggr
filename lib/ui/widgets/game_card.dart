import 'package:flutter/material.dart';

class GameCard extends StatefulWidget {
  final String title;
  final String imageUrl;
  final VoidCallback onTap;

  const GameCard({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  State<GameCard> createState() => _GameCardState();
}

class _GameCardState extends State<GameCard> {
  bool _isPressed = false;

  void _setPressedState(bool pressed) {
    if (!mounted) return;

    // Safely defer setState execution if the widget tree is locked mid-frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _isPressed != pressed) {
        setState(() => _isPressed = pressed);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(0),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Base Image
          Image.network(
            widget.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[800],
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(Icons.sports_esports, color: Colors.white54),
                    Text(widget.title, textAlign: TextAlign.center),
                  ],
                ),
              );
            },
          ),

          // 2. Dark Overlay Layer (Visible only when touched)
          // if (_isPressed)
          //   Positioned.fill(
          //     child: Container(
          //       color: Colors.black.withValues(alpha: 0.4), // 40% dark overlay
          //     ),
          //   ),

          // 3. Touch Listener Layer on Top
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                onTapDown: (_) => _setPressedState(true),
                onTapUp: (_) => _setPressedState(false),
                onTapCancel: () => _setPressedState(false),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
