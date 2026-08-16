class DiaryEntry {
  final int id;
  final String perfumeExternalId;
  final String perfumeName;
  final String? brand;
  final String? imageUrl;
  final DateTime usedAt;
  final int? rating;
  final String? longevity;
  final String? sillage;
  final String? occasion;
  final String? weather;
  final String? notes;
  const DiaryEntry({required this.id, required this.perfumeExternalId, required this.perfumeName, this.brand, this.imageUrl, required this.usedAt, this.rating, this.longevity, this.sillage, this.occasion, this.weather, this.notes});
  factory DiaryEntry.fromJson(Map<String, dynamic> json) => DiaryEntry(id: json['id'] as int, perfumeExternalId: json['perfumeExternalId'] as String, perfumeName: json['perfumeName'] as String, brand: json['brand'] as String?, imageUrl: json['imageUrl'] as String?, usedAt: DateTime.parse(json['usedAt'] as String), rating: json['rating'] as int?, longevity: json['longevity'] as String?, sillage: json['sillage'] as String?, occasion: json['occasion'] as String?, weather: json['weather'] as String?, notes: json['notes'] as String?);
}
