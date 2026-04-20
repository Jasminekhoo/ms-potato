import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/config.dart';
import '../models/analysis_result.dart';
import '../models/compare_result.dart';
import '../models/property_input.dart';

class ApiService {
  final _client = http.Client();

  Future<AnalysisResult> analyse(PropertyInput input) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/analyse');

    try {
      final response = await _client
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(input.toJson()),
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return AnalysisResult.fromJson(
            jsonDecode(response.body) as Map<String, dynamic>);
      }
    } catch (_) {
      // Keep demo resilient by falling back to static data.
    }

    return AnalysisResult(
      verdict: 'ACCEPTABLE',
      explanation:
          'Asking rent is close to postcode median, but hidden move-in costs push first-year burden higher than expected.',
      listedRent: input.askingRent,
      trueCostMonthly: input.askingRent + 320,
      hiddenCosts: {
        'Parking': 180,
        'Utilities Deposit (amortized)': 70,
        'Access Card + Setup': 40,
        'Internet Setup': 30,
      },
      riskScore: 5.9,
      riskSummary:
          'Multiple tenant mentions of lift downtime and delayed management response in the past 12 months.',
      negotiationTips: const [
        'Ask for RM200 rent reduction citing nearby comps at lower rates.',
        'Request 1 free parking bay or equivalent rebate.',
        'Include a clear repair SLA clause before signing.',
      ],
      confidenceScore: 0.74,
      dataFreshness: 'Updated 3 days ago',
      sources: [
        AnalysisSource(
          title: 'KL Tenant Forum - Midcity Heights thread',
          url: 'https://example.com/forum/midcity-heights',
          snippet:
              'Several tenants reported repeated lift downtime and delayed management response in 2025.',
        ),
        AnalysisSource(
          title: 'Google Reviews - Building Facilities',
          url: 'https://example.com/reviews/midcity-heights',
          snippet:
              'Multiple mentions of slow maintenance turnaround for common facilities.',
        ),
      ],
    );
  }

  Future<List<CompareProperty>> compare(List<PropertyInput> properties) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/compare');

    try {
      final response = await _client
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'properties': properties.map((p) => p.toJson()).toList(),
            }),
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final list = (decoded['items'] as List?) ?? const [];
        return list
            .map((e) => CompareProperty.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {
      // Fall through to static comparison cards.
    }

    final fallback = <Map<String, dynamic>>[
      {
        'name': 'Vista Harmoni Residences',
        'location': 'Cheras',
        'verdict': 'GREAT DEAL',
        'trueCostMonthly': 2050.0,
        'riskScore': 3.2,
      },
      {
        'name': 'Midcity Heights',
        'location': 'Taman Midah',
        'verdict': 'ACCEPTABLE',
        'trueCostMonthly': 2320.0,
        'riskScore': 5.8,
      },
      {
        'name': 'Lakepoint Suites',
        'location': 'Sri Petaling',
        'verdict': 'AVOID',
        'trueCostMonthly': 2590.0,
        'riskScore': 8.1,
      },
    ];

    return fallback.map((e) => CompareProperty.fromJson(e)).toList();
  }
}
