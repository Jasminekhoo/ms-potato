class AnalysisResult {
  final String verdict;
  final String explanation;
  final double listedRent;
  final double trueCostMonthly;
  final Map<String, double> hiddenCosts;
  final double riskScore;
  final String riskSummary;
  final List<String> negotiationTips;
  final double confidenceScore;
  final String dataFreshness;
  final List<AnalysisSource> sources;
  // New fields from your console output
  final String label;
  final String suggestion;

  AnalysisResult({
    required this.verdict,
    required this.explanation,
    required this.listedRent,
    required this.trueCostMonthly,
    required this.hiddenCosts,
    required this.riskScore,
    required this.riskSummary,
    required this.negotiationTips,
    required this.confidenceScore,
    required this.dataFreshness,
    required this.sources,
    required this.label,
    required this.suggestion,
  });

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    final costs = json['hiddenCosts'] as Map<String, dynamic>? ?? {};
    final mappedCosts = costs.map((key, value) => MapEntry(key, (value as num).toDouble()));
    final affordability = json['affordability'] as Map<String, dynamic>? ?? {};

    return AnalysisResult(
      verdict: json['verdict'] ?? 'UNKNOWN',
      explanation: json['explanation'] ?? '',
      listedRent: (json['listedRent'] as num?)?.toDouble() ?? 0.0,
      trueCostMonthly: (json['trueCostMonthly'] as num?)?.toDouble() ?? 0.0,
      hiddenCosts: mappedCosts,
      riskScore: (json['riskScore'] as num?)?.toDouble() ?? 0.0,
      riskSummary: json['riskSummary'] ?? '',
      negotiationTips: List<String>.from(json['negotiationTips'] ?? []),
      confidenceScore: (json['confidenceScore'] as num?)?.toDouble() ?? 0.0,
      dataFreshness: json['dataFreshness'] ?? 'N/A',
      sources: (json['sources'] as List?)?.map((e) => AnalysisSource.fromJson(e)).toList() ?? [],
      label: affordability['label'] ?? 'NORMAL',
      suggestion: affordability['suggestion'] ?? '',
    );
  }
}

class AnalysisSource {
  AnalysisSource({
    required this.title,
    required this.url,
    required this.snippet,
  });

  final String title;
  final String url;
  final String snippet;

  factory AnalysisSource.fromJson(Map<String, dynamic> json) {
    return AnalysisSource(
      title: (json['title'] ?? '').toString(),
      url: (json['url'] ?? '').toString(),
      snippet: (json['snippet'] ?? '').toString(),
    );
  }
}
