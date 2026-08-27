import 'perfume.dart';

class PerfumeRecommendation {
  final Perfume perfume;
  final double score;
  final String reason;

  const PerfumeRecommendation({required this.perfume, required this.score, required this.reason});

  factory PerfumeRecommendation.fromJson(Map<String, dynamic> json) => PerfumeRecommendation(
        perfume: Perfume.fromJson(json),
        score: (json['score'] as num?)?.toDouble() ?? 0,
        reason: json['reason'] as String? ?? 'Combina com sua coleção.',
      );
}
