import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/analysis_result.dart';

class SourceTransparencyCard extends StatelessWidget {
  const SourceTransparencyCard({
    super.key,
    required this.confidenceScore,
    required this.dataFreshness,
    required this.sources,
  });

  final double confidenceScore;
  final String dataFreshness;
  final List<AnalysisSource> sources;

  Future<void> _openUrl(BuildContext context, String value) async {
    final uri = Uri.tryParse(value);
    if (uri == null) return;

    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open source link.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final normalized = confidenceScore.clamp(0.0, 1.0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Source Transparency',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Text(
              'Confidence: ${(normalized * 100).toStringAsFixed(0)}%',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2FE),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                dataFreshness,
                style: const TextStyle(
                  color: Color(0xFF075985),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                minHeight: 10,
                value: normalized,
                backgroundColor: const Color(0xFFE5E7EB),
              ),
            ),
            const SizedBox(height: 14),
            if (sources.isEmpty)
              const Text(
                'No source links were provided for this result. Treat this recommendation with extra caution.',
              )
            else
              ...sources.take(4).map(
                    (source) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            source.title,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          if (source.snippet.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                source.snippet,
                                style: const TextStyle(color: Colors.black87),
                              ),
                            ),
                          if (source.url.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: InkWell(
                                onTap: () => _openUrl(context, source.url),
                                child: Text(
                                  source.url,
                                  style: const TextStyle(
                                    color: Color(0xFF0E7490),
                                    fontSize: 12,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
