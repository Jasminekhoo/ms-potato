import 'package:flutter/material.dart';

import '../../widgets/layout/app_scaffold.dart';

class BuyVsRentScreen extends StatelessWidget {
  const BuyVsRentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Buy vs Rent',
      child: ListView(
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF115E59), Color(0xFF164E63)],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Text(
              'Breakeven estimate: Buying overtakes renting after 8.4 years under current assumptions.',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 14),
          const Row(
            children: [
              Expanded(
                child: _MetricCard(
                  title: 'Monthly Rent Path',
                  value: 'RM 2,200 -> RM 2,530 (24 months)',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _MetricCard(
                  title: 'Monthly Mortgage',
                  value: 'RM 2,980 @ 4.1% financing',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const _MetricCard(
            title: 'Opportunity Cost Signal',
            value:
                'Down payment invested at 4% could offset RM 410/mo equivalent over 24 months.',
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(value),
          ],
        ),
      ),
    );
  }
}
