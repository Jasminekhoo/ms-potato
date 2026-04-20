class CompareProperty {
  CompareProperty({
    required this.name,
    required this.location,
    required this.verdict,
    required this.trueCostMonthly,
    required this.riskScore,
  });

  final String name;
  final String location;
  final String verdict;
  final double trueCostMonthly;
  final double riskScore;

  factory CompareProperty.fromJson(Map<String, dynamic> json) {
    return CompareProperty(
      name: (json['name'] ?? '').toString(),
      location: (json['location'] ?? '').toString(),
      verdict: (json['verdict'] ?? 'ACCEPTABLE').toString(),
      trueCostMonthly: (json['trueCostMonthly'] as num?)?.toDouble() ?? 0,
      riskScore: (json['riskScore'] as num?)?.toDouble() ?? 0,
    );
  }
}
