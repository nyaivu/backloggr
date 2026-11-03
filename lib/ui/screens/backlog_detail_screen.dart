import 'package:backloggr/data/models/backlog_item.dart';
import 'package:backloggr/data/services/supabase_service.dart';
import 'package:flutter/material.dart';

class BacklogDetailScreen extends StatefulWidget {
  final String id;

  const BacklogDetailScreen({super.key, required this.id});

  @override
  State<BacklogDetailScreen> createState() => _BacklogDetailScreenState();
}

class _BacklogDetailScreenState extends State<BacklogDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Text(widget.id),
            FutureBuilder(
              future: SupabaseService().fetchBacklogByID(widget.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  final BacklogItem item = snapshot.data!;

                  return Text(item.gameTitle);
                } else {
                  return Text("Invalid item.");
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
