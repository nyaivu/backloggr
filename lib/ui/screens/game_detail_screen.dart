import 'package:backloggr/data/services/cheapshark_api_service.dart';
import 'package:flutter/material.dart';

class GameDetailScreen extends StatefulWidget {
  final String id;

  const GameDetailScreen({super.key, required this.id});

  @override
  State<GameDetailScreen> createState() => _GameDetailScreenState();
}

class _GameDetailScreenState extends State<GameDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Text(widget.id),
            // FutureBuilder(future: CheapSharkApiService().fetchGameDetail(widget.id), builder: (context, index) {

            // })
          ],
        ),
      ),
    );
  }
}
