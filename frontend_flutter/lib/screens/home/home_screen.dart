import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../widgets/common/primary_button.dart';
import '../../widgets/common/staggered_reveal.dart';
import '../../widgets/layout/app_scaffold.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      child: ListView(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F766E), Color(0xFF0EA5E9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'See the rent truth before you sign.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'AI Rent Advisor reveals hidden fees, landlord risk patterns, and gives negotiation scripts in plain language.',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 230,
                  child: PrimaryButton(
                    label: 'Start Analysis',
                    onPressed: () => context.go('/input'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const _QuickTileRow(),
        ],
      ),
    );
  }
}

class _QuickTileRow extends StatelessWidget {
  const _QuickTileRow();

  @override
  Widget build(BuildContext context) {
    const tiles = [
      _Tile(
          title: 'Rental Verdict', subtitle: 'Great Deal / Acceptable / Avoid'),
      _Tile(title: 'True Cost', subtitle: 'First-year monthly average'),
      _Tile(title: 'Risk Radar', subtitle: 'Pattern-based complaint signals'),
      _Tile(title: 'Negotiation Coach', subtitle: '3 talking points to use'),
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: List.generate(
        tiles.length,
        (index) => StaggeredReveal(index: index, child: tiles[index]),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(subtitle, style: const TextStyle(color: Colors.black54)),
            ],
          ),
        ),
      ),
    );
  }
}
