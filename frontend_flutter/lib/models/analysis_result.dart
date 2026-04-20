class AnalysisResult {
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
  });

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

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    final dynamic costs = json['hiddenCosts'];
    final mappedCosts = <String, double>{};
    if (costs is Map) {
      for (final entry in costs.entries) {
        mappedCosts[entry.key.toString()] = (entry.value as num).toDouble();
      }
    }

    final parsedSources = <AnalysisSource>[];
    final dynamic sourceJson = json['sources'];
    if (sourceJson is List) {
      for (final source in sourceJson) {
        if (source is Map<String, dynamic>) {
          parsedSources.add(AnalysisSource.fromJson(source));
        } else if (source is String) {
          parsedSources.add(
            AnalysisSource(title: source, url: '', snippet: ''),
          );
        }
      }
    }

    return AnalysisResult(
      verdict: (json['verdict'] ?? 'ACCEPTABLE').toString(),
      explanation: (json['explanation'] ?? '').toString(),
      listedRent: (json['listedRent'] as num?)?.toDouble() ?? 0,
      trueCostMonthly: (json['trueCostMonthly'] as num?)?.toDouble() ?? 0,
      hiddenCosts: mappedCosts,
      riskScore: (json['riskScore'] as num?)?.toDouble() ?? 0,
      riskSummary: (json['riskSummary'] ?? '').toString(),
      negotiationTips: ((json['negotiationTips'] as List?) ?? const [])
          .map((e) => e.toString())
          .toList(),
      confidenceScore: (json['confidenceScore'] as num?)?.toDouble() ?? 0.62,
      dataFreshness: (json['dataFreshness'] ?? 'Updated 2 days ago').toString(),
      sources: parsedSources,
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
