/// Represents a personal game backlog item saved in the database (Supabase/SQLite).
class BacklogItem {
  final int? id;
  final String userId;
  final int gameId;
  final String gameTitle;
  final String? coverUrl;
  final String? capsuleUrl;
  final String completionStatus;
  final String? reviewNotes;
  final DateTime? createdAt;

  BacklogItem({
    this.id,
    required this.userId,
    required this.gameId,
    required this.gameTitle,
    this.coverUrl,
    this.capsuleUrl,
    this.completionStatus = 'Backlog',
    this.reviewNotes,
    this.createdAt,
  });

  /// Factory constructor to instantiate a BacklogItem from JSON (Database Response)
  factory BacklogItem.fromJson(Map<String, dynamic> json) {
    return BacklogItem(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id'].toString()),
      userId: json['user_id']?.toString() ?? '',
      gameId: json['game_id'] is int
          ? json['game_id'] as int
          : int.parse(json['game_id'].toString()),
      gameTitle: json['game_title'] as String? ?? 'Unknown Title',
      coverUrl: json['cover_url'] as String?,
      capsuleUrl: json['capsule_url'] as String?,
      completionStatus: json['completion_status'] as String? ?? 'Backlog',
      reviewNotes: json['review_notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  /// Converts a BacklogItem instance into a Map/JSON for Insert & Update operations
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'user_id': userId,
      'game_id': gameId,
      'game_title': gameTitle,
      'cover_url': coverUrl,
      'capsule_url': capsuleUrl,
      'completion_status': completionStatus,
      'review_notes': reviewNotes,
    };

    // Include primary key ID only when updating existing records
    if (id != null) {
      map['id'] = id;
    }

    return map;
  }

  /// Creates a modified copy of BacklogItem while keeping unchanged fields
  BacklogItem copyWith({
    int? id,
    String? userId,
    int? gameId,
    String? gameTitle,
    String? coverUrl,
    String? capsuleUrl,
    String? completionStatus,
    String? reviewNotes,
    DateTime? createdAt,
  }) {
    return BacklogItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      gameId: gameId ?? this.gameId,
      gameTitle: gameTitle ?? this.gameTitle,
      coverUrl: coverUrl ?? this.coverUrl,
      capsuleUrl: capsuleUrl ?? this.capsuleUrl,
      completionStatus: completionStatus ?? this.completionStatus,
      reviewNotes: reviewNotes ?? this.reviewNotes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
