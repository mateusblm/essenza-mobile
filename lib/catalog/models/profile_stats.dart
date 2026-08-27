class ProfileStats {
  final int perfumeCount;
  final int favoritesCount;
  final int wishlistCount;
  final int diaryEntryCount;

  const ProfileStats({required this.perfumeCount, required this.favoritesCount, required this.wishlistCount, required this.diaryEntryCount});

  factory ProfileStats.fromJson(Map<String, dynamic> json) => ProfileStats(
        perfumeCount: json['perfumeCount'] as int? ?? 0,
        favoritesCount: json['favoritesCount'] as int? ?? 0,
        wishlistCount: json['wishlistCount'] as int? ?? 0,
        diaryEntryCount: json['diaryEntryCount'] as int? ?? 0,
      );
}
