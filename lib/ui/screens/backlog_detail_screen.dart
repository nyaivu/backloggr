import 'package:backloggr/core/constants.dart';
import 'package:backloggr/data/models/backlog_item.dart';
import 'package:backloggr/data/providers/backlog_notifier.dart';
import 'package:backloggr/data/services/supabase_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_flutter/dropdown_flutter.dart';
import 'package:exui/exui.dart';
import 'package:provider/provider.dart';

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
      await SupabaseService().updateBacklogItem(updatedItem);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
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

  Future<void> _handleDelete(BuildContext context, int id, String title) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.scaffoldBackground,
        title: const Text(
          'Delete Game',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to remove "$title" from your backlog?',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('CANCEL', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.steamDiscountRed,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('DELETE', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      try {
        await context.read<BacklogProvider>().deleteItem(id);

        if (context.mounted) {
          Navigator.of(context).pop(); // Return to previous screen
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$title removed from backlog.'),
              backgroundColor: AppColors.steamGreen,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete: ${e.toString()}'),
              backgroundColor: AppColors.steamDiscountRed,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<BacklogItem?>(
      future: _backlogFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: AppColors.scaffoldBackground,
            appBar: AppBar(
              title: const Text("DETAILS"),
              centerTitle: true,
              backgroundColor: AppColors.scaffoldBackground,
              iconTheme: const IconThemeData(color: AppColors.textPrimary),
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError ||
            !snapshot.hasData ||
            snapshot.data == null) {
          return Scaffold(
            backgroundColor: AppColors.scaffoldBackground,
            appBar: AppBar(
              title: const Text("DETAILS"),
              centerTitle: true,
              backgroundColor: AppColors.scaffoldBackground,
              iconTheme: const IconThemeData(color: AppColors.textPrimary),
            ),
            body: Center(
              child: Text(
                snapshot.hasError
                    ? 'Error: ${snapshot.error}'
                    : 'Item not found.',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          );
        }

        final BacklogItem item = snapshot.data!;

        if (!_isInitialized) {
          _notesController.text = item.reviewNotes ?? "";
          _selectedStatus = item.completionStatus;
          _isInitialized = true;
        }

        return Scaffold(
          backgroundColor: AppColors.scaffoldBackground,
          appBar: AppBar(
            title: Text(
              item.gameTitle.toUpperCase(),
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            actions: [
              if (item.id != null)
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                  ),
                  tooltip: 'Delete Game',
                  onPressed: () =>
                      _handleDelete(context, item.id!, item.gameTitle),
                ),
            ],
            iconTheme: const IconThemeData(color: AppColors.textPrimary),
            centerTitle: true,
            backgroundColor: AppColors.scaffoldBackground,
            scrolledUnderElevation: 0.0,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 16,
                  children: [
                    if (item.capsuleUrl != null && item.capsuleUrl!.isNotEmpty)
                      CachedNetworkImage(
                        imageUrl: item.capsuleUrl!,
                        fit: BoxFit.cover,
                        errorWidget: (context, error, stackTrace) {
                          return Container(
                            height: 180,
                            color: Colors.grey[800],
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
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
                    Text(
                      item.gameTitle,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      width: 256,
                      child: DropdownFlutter<String>(
                        hideSelectedFieldWhenExpanded: false,
                        hintText: 'Select priority',
                        items: const ['Backlog', 'Playing', 'Completed'],
                        initialItem: item.completionStatus,
                        onChanged: (value) => _selectedStatus = value!,
                      ),
                    ),
                    Column(
                      spacing: 4,
                      children: [
                        const Text("Notes", style: TextStyle(fontSize: 16)),
                        const Text(
                          "Note your progress and thoughts about the game",
                          style: TextStyle(fontSize: 14),
                        ),
                        TextField(
                          maxLines: 12,
                          minLines: 6,
                          controller: _notesController,
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: AppColors.gray300,
                            hintText: "Notes go here...",
                          ),
                          style: const TextStyle(color: AppColors.gray950),
                        ).paddingAll(16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.steamBlue.withAlpha(
                                  20,
                                ),
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
                                _isLoading ? 'SAVING...' : 'SAVE CHANGES',
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
              ),
            ),
          ),
        );
      },
    );
  }
}
