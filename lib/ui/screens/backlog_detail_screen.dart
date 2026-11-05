import 'package:backloggr/core/constants.dart';
import 'package:backloggr/data/models/backlog_item.dart';
import 'package:backloggr/data/services/supabase_service.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_flutter/dropdown_flutter.dart';
import 'package:exui/exui.dart';

class BacklogDetailScreen extends StatefulWidget {
  final String id;

  const BacklogDetailScreen({super.key, required this.id});

  @override
  State<BacklogDetailScreen> createState() => _BacklogDetailScreenState();
}

class _BacklogDetailScreenState extends State<BacklogDetailScreen> {
  final TextEditingController _notesController = TextEditingController();
  late Future<BacklogItem?> _backlogFuture;

  String _selectedStatus = "Backlog";
  bool _isInitialized = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // 1. Fetch future ONCE during initialization so builds don't re-trigger fetch
    _backlogFuture = SupabaseService().fetchBacklogByID(widget.id);
  }

  Future<void> _handleSaveChanges(
    BacklogItem existingItem,
    String completionStatus,
    String notes,
  ) async {
    setState(() => _isLoading = true);

    final updatedItem = existingItem.copyWith(
      completionStatus: _selectedStatus,
      reviewNotes: _notesController.text.trim(),
    );
    try {
      print(_notesController.text.trim());
      await SupabaseService().updateBacklogItem(updatedItem);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Changes saved successfully!'),
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
        body: Column(
          children: [
            FutureBuilder(
              future: _backlogFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  final BacklogItem item = snapshot.data!;

                  if (!_isInitialized) {
                    _notesController.text = item.reviewNotes ?? "";
                    _selectedStatus = item.completionStatus;
                    _isInitialized = true;
                  }

                  return SizedBox(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 16,
                      children: [
                        Image.network(
                          item.capsuleUrl!,
                          fit: BoxFit.cover,
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
                            items: const ['Backlog', 'Playing', 'Completed'],
                            initialItem: item.completionStatus, // optional
                            onChanged: (value) => _selectedStatus = value!,
                          ),
                        ),
                        Column(
                          spacing: 4,
                          children: [
                            Text("Notes", style: TextStyle(fontSize: 16)),
                            Text(
                              "Note your progress and thoughts about the game",
                              style: TextStyle(fontSize: 14),
                            ),
                            TextField(
                              maxLines: 12,
                              minLines: 6,
                              controller: _notesController,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: AppColors.gray300,
                                hintText: "Notes go here...",
                              ),
                              style: TextStyle(color: AppColors.gray950),
                            ).paddingAll(16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.steamBlue
                                        .withAlpha(20),
                                    foregroundColor: AppColors.steamBlue,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                  ),
                                  onPressed: _isLoading
                                      ? null
                                      : () => _handleSaveChanges(
                                          item,
                                          _selectedStatus,
                                          _notesController.text,
                                        ),
                                  icon: _isLoading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Icon(Icons.save_rounded),
                                  label: Text(
                                    _isLoading ? 'Adding...' : 'SAVE CHANGES',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ),
                              ],
                            ).paddingHorizontal(16),
                          ],
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
    );
  }
}
