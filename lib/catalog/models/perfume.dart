class Perfume {
  final String externalId;
  final String name;
  final String? brand;
  final String? imageUrl;
  final int? releaseYear;
  final double? rating;
  final String? gender;
  final String? oilType;
  final String? longevity;
  final String? sillage;
  final List<String> notes;
  final List<String> mainAccords;
  final Map<String, double> mainAccordsPercentage;
  final List<PerfumeRanking> seasonRanking;
  final List<PerfumeRanking> occasionRanking;

  const Perfume({required this.externalId, required this.name, this.brand, this.imageUrl, this.releaseYear, this.rating, this.gender, this.oilType, this.longevity, this.sillage, this.notes = const [], this.mainAccords = const [], this.mainAccordsPercentage = const {}, this.seasonRanking = const [], this.occasionRanking = const []});

  factory Perfume.fromJson(Map<String, dynamic> json) => Perfume(
    externalId: json['externalId'] as String, name: json['name'] as String,
    brand: json['brand'] is Map<String, dynamic> ? (json['brand'] as Map<String, dynamic>)['name'] as String? : json['brand'] as String?, imageUrl: json['imageUrl'] as String?,
    releaseYear: json['releaseYear'] as int?, rating: (json['rating'] as num?)?.toDouble(), gender: json['gender'] as String?, oilType: json['oilType'] as String?,
    longevity: json['longevity'] as String?, sillage: json['sillage'] as String?,
    notes: (json['notes'] as List<dynamic>? ?? []).map((e) => e is Map<String, dynamic> ? e['name'] as String : e.toString()).toList(),
    mainAccords: (json['mainAccords'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
    mainAccordsPercentage: ((json['mainAccordsPercentage'] as Map<String, dynamic>?) ?? {}).map((key, value) => MapEntry(key, _parseAccordWeight(value))),
    seasonRanking: (json['seasonRanking'] as List<dynamic>? ?? []).map((e) => PerfumeRanking.fromJson(e as Map<String, dynamic>)).toList(),
    occasionRanking: (json['occasionRanking'] as List<dynamic>? ?? []).map((e) => PerfumeRanking.fromJson(e as Map<String, dynamic>)).toList(),
  );
}

double _parseAccordWeight(Object? value) {
  final numeric = double.tryParse(value.toString().replaceAll('%', '').replaceAll(',', '.'));
  if (numeric != null) return numeric > 1 ? numeric / 100 : numeric;
  return switch (value.toString().toLowerCase()) {
    'dominant' => 1.0,
    'prominent' => 0.75,
    'moderate' => 0.5,
    'minor' || 'slight' => 0.25,
    _ => 0.0,
  };
}

class PerfumeRanking {
  final String name;
  final double score;

  const PerfumeRanking(this.name, this.score);

  factory PerfumeRanking.fromJson(Map<String, dynamic> json) => PerfumeRanking(
        json['name'] as String,
        (json['score'] as num?)?.toDouble() ?? 0,
      );
}

class SearchResult {
  final List<Perfume> items;
  final int total;
  const SearchResult(this.items, this.total);
  factory SearchResult.fromJson(Map<String, dynamic> json) => SearchResult((json['items'] as List<dynamic>? ?? []).map((e) => Perfume.fromJson(e as Map<String, dynamic>)).toList(), json['total'] as int? ?? 0);
}
