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
    return const Placeholder();
  }
}
