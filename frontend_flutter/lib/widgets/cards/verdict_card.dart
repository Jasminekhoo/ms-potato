import 'package:flutter/material.dart';

class VerdictCard extends StatelessWidget {
  const VerdictCard({
    super.key,
    required this.verdict,
    required this.explanation,
  });

  final String verdict;
  final String explanation;

  Color _color(String value) {
    final v = value.toUpperCase();
    if (v.contains('GREAT')) return const Color(0xFF15803D);
    if (v.contains('AVOID')) return const Color(0xFFB91C1C);
    return const Color(0xFF0F766E);
  }

  @override
  Widget build(BuildContext context) {
    final chipColor = _color(verdict);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Rental Verdict',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: chipColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                verdict,
                style: TextStyle(color: chipColor, fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(height: 12),
            Text(explanation, style: const TextStyle(height: 1.4)),
          ],
        ),
      ),
    );
  }
}
