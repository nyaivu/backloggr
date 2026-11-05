import 'package:backloggr/core/constants.dart';
import 'package:backloggr/data/models/backlog_item.dart';
import 'package:backloggr/data/services/supabase_service.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_flutter/dropdown_flutter.dart';

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
        appBar: AppBar(
          title: Text(
            "DETAILS",
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          iconTheme: IconThemeData(
            color: AppColors.textPrimary, // Change your color here
          ),
          centerTitle: true,
          backgroundColor: AppColors.scaffoldBackground,
          scrolledUnderElevation: 0.0,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              FutureBuilder(
                future: SupabaseService().fetchBacklogByID(widget.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (snapshot.hasData) {
                    final BacklogItem item = snapshot.data!;

                    return SizedBox(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        spacing: 8,
                        children: [
                          Image.network(
                            item.coverUrl!,
                            fit: BoxFit.cover,
                            height: 200,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[800],
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.sports_esports,
                                      color: Colors.white54,
                                    ),
                                    Text(
                                      item.gameTitle,
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          Text(item.gameTitle, style: TextStyle(fontSize: 20)),
                          SizedBox(
                            width: 256,
                            child: DropdownFlutter<String>(
                              hideSelectedFieldWhenExpanded: false,
                              hintText: 'Select priority',
                              items: const [
                                'Unfinished',
                                'Playing',
                                'Completed',
                              ],
                              initialItem: item.completionStatus, // optional
                              onChanged: (value) => print(value),
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return Text("Invalid item.");
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
