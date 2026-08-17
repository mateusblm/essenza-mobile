class CollectionInsightScore {
  final String label;
  final double percentage;

  const CollectionInsightScore({required this.label, required this.percentage});

  factory CollectionInsightScore.fromJson(Map<String, dynamic> json) =>
      CollectionInsightScore(
        label: json['label'] as String,
        percentage: (json['percentage'] as num?)?.toDouble() ?? 0,
      );
}

class CollectionInsights {
  final int perfumeCount;
  final List<CollectionInsightScore> olfactiveProfile;
  final List<CollectionInsightScore> climates;
  final List<String> occasions;
  final List<String> recommendations;

  const CollectionInsights({
    required this.perfumeCount,
    required this.olfactiveProfile,
    required this.climates,
    required this.occasions,
    required this.recommendations,
  });

  factory CollectionInsights.fromJson(Map<String, dynamic> json) =>
      CollectionInsights(
        perfumeCount: json['perfumeCount'] as int? ?? 0,
        olfactiveProfile: _scores(json['olfactiveProfile']),
        climates: _scores(json['climates']),
        occasions: (json['occasions'] as List<dynamic>? ?? [])
            .map((item) => item.toString())
            .toList(),
        recommendations: (json['recommendations'] as List<dynamic>? ?? [])
            .map((item) => item.toString())
            .toList(),
      );
}

List<CollectionInsightScore> _scores(Object? value) =>
    (value as List<dynamic>? ?? [])
        .map(
          (item) =>
              CollectionInsightScore.fromJson(item as Map<String, dynamic>),
        )
        .toList();
