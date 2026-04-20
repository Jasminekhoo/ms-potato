import 'package:flutter/material.dart';

class RiskRadarCard extends StatelessWidget {
  const RiskRadarCard({
    super.key,
    required this.score,
    required this.summary,
  });

  final double score;
  final String summary;

  @override
  Widget build(BuildContext context) {
    final normalized = (score / 10).clamp(0.0, 1.0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Risk Radar', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                minHeight: 12,
                value: normalized,
                backgroundColor: const Color(0xFFE5E7EB),
              ),
            ),
            const SizedBox(height: 8),
            Text('Risk score: ${score.toStringAsFixed(1)}/10'),
            const SizedBox(height: 10),
            Text(summary, style: const TextStyle(height: 1.4)),
          ],
        ),
      ),
    );
  }
}
