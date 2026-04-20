import 'package:flutter/material.dart';

import '../../core/utils.dart';

class CostBreakdownCard extends StatelessWidget {
  const CostBreakdownCard({
    super.key,
    required this.listedRent,
    required this.trueCost,
    required this.hiddenCosts,
  });

  final double listedRent;
  final double trueCost;
  final Map<String, double> hiddenCosts;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('True All-In Cost',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 14),
            Row(
              children: [
                _CostPill(label: 'Listed', value: Currency.rm(listedRent)),
                const SizedBox(width: 8),
                _CostPill(
                    label: 'Real (1st Year Avg)', value: Currency.rm(trueCost)),
              ],
            ),
            const SizedBox(height: 14),
            ...hiddenCosts.entries.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(child: Text(e.key)),
                    Text(Currency.rm(e.value)),
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

class _CostPill extends StatelessWidget {
  const _CostPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(fontSize: 12, color: Colors.black54)),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
