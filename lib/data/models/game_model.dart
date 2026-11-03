/// Data model for representing game deals and catalog items from CheapShark API.
class GameModel {
  final String dealID;
  final String gameID;
  final String title;
  final String storeID;
  final double salePrice;
  final double normalPrice;
  final bool isOnSale;
  final double savings;
  final int metacriticScore;
  final String? steamRatingText;
  final int steamRatingPercent;
  final int steamRatingCount;
  final String? steamAppID;
  final String thumb;
  final double dealRating;

  GameModel({
    required this.dealID,
    required this.gameID,
    required this.title,
    required this.storeID,
    required this.salePrice,
    required this.normalPrice,
    required this.isOnSale,
    required this.savings,
    required this.metacriticScore,
    this.steamRatingText,
    required this.steamRatingPercent,
    required this.steamRatingCount,
    this.steamAppID,
    required this.thumb,
    required this.dealRating,
  });

  /// Factory constructor for parsing responses from `/api/1.0/deals`
  factory GameModel.fromDealJson(Map<String, dynamic> json) {
    return GameModel(
      dealID: json['dealID'] as String? ?? '',
      gameID: json['gameID'] as String? ?? '',
      title: json['title'] as String? ?? 'Unknown Title',
      storeID: json['storeID'] as String? ?? '1',
      salePrice: double.tryParse(json['salePrice']?.toString() ?? '0.0') ?? 0.0,
      normalPrice:
          double.tryParse(json['normalPrice']?.toString() ?? '0.0') ?? 0.0,
      isOnSale: json['isOnSale'] == '1' || json['isOnSale'] == true,
      savings: double.tryParse(json['savings']?.toString() ?? '0.0') ?? 0.0,
      metacriticScore:
          int.tryParse(json['metacriticScore']?.toString() ?? '0') ?? 0,
      steamRatingText: json['steamRatingText'] as String?,
      steamRatingPercent:
          int.tryParse(json['steamRatingPercent']?.toString() ?? '0') ?? 0,
      steamRatingCount:
          int.tryParse(json['steamRatingCount']?.toString() ?? '0') ?? 0,
      steamAppID: json['steamAppID'] as String?,
      thumb: json['thumb'] as String? ?? '',
      dealRating:
          double.tryParse(json['dealRating']?.toString() ?? '0.0') ?? 0.0,
    );
  }

  /// Factory constructor for parsing global search lookup from `/api/1.0/games`
  factory GameModel.fromGameSearchJson(Map<String, dynamic> json) {
    final cheapestPrice =
        double.tryParse(json['cheapest']?.toString() ?? '0.0') ?? 0.0;

    return GameModel(
      dealID: json['cheapestDealID'] as String? ?? '',
      gameID: json['gameID'] as String? ?? '',
      title: json['external'] as String? ?? 'Unknown Title',
      storeID: '1',
      salePrice: cheapestPrice,
      normalPrice: cheapestPrice,
      isOnSale: false,
      savings: 0.0,
      metacriticScore: 0,
      steamRatingText: null,
      steamRatingPercent: 0,
      steamRatingCount: 0,
      steamAppID: json['steamAppID'] as String?,
      thumb: json['thumb'] as String? ?? '',
      dealRating: 0.0,
    );
  }

  String get verticalCoverUrl {
    // Jika steamAppID valid, langsung gunakan asset Library Capsule 600x900 milik Steam
    if (steamAppID != null &&
        steamAppID!.trim().isNotEmpty &&
        steamAppID != '0' &&
        steamAppID != 'null') {
      return 'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/$steamAppID/library_600x900_2x.jpg';
    }

    // Fallback ke gambar HD horizontal jika bukan game Steam
    return hdCoverUrl;
  }

  /// Returns a high-definition image URL by substituting low-res thumbnail paths
  String get hdCoverUrl {
    // 1. Cek secara eksplisit apakah steamAppID valid (bukan null, bukan kosong, dan bukan '0')
    if (steamAppID != null &&
        steamAppID!.trim().isNotEmpty &&
        steamAppID != '0' &&
        steamAppID != 'null') {
      return 'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/$steamAppID/header.jpg';
    }

    // 2. Jika tidak ada steamAppID, gunakan thumbnail asli bawaan API
    if (thumb.isNotEmpty) {
      // Ubah ukuran jika merupakan gambar Steam capsule
      if (thumb.contains('capsule_231x87')) {
        return thumb.replaceAll(
          RegExp(r'capsule_\d+x\d+(_alt_assets_\d+)?\.jpg'),
          'header.jpg',
        );
      }
      // Ubah ukuran jika merupakan gambar GamersGate
      if (thumb.contains('cover-180')) {
        return thumb.replaceAll('cover-180', 'cover-600');
      }
      return thumb;
    }

    // 3. Placeholder bawaan jika thumb kosong
    return 'https://via.placeholder.com/460x215.png?text=No+Cover';
  }

  /// Formatted savings display (e.g. "40%")
  String get formattedSavings => '${savings.round()}%';
}
