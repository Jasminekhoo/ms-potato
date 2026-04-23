import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../widgets/common/primary_button.dart';
import '../../widgets/layout/app_scaffold.dart';

class LandlordHomeScreen extends StatelessWidget {
  const LandlordHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Landlord Dashboard',
      child: ListView(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F766E), Color(0xFFF59E0B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome, Landlord',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Monitor tenant payments, rate tenants, and manage properties from one place.',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    SizedBox(
                      width: 170,
                      child: PrimaryButton(
                        label: 'Payments',
                        onPressed: () => context.go('/payments'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 170,
                      child: OutlinedButton(
                        onPressed: () => context.go('/profile'),
                        child: const Text('Profile'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const _FeatureGrid(
            title: 'Landlord Tools',
            items: [
              _FeatureItem(
                title: 'Payment Tracking',
                subtitle: 'See whether rent was paid on time or late.',
                icon: Icons.payments_outlined,
              ),
              _FeatureItem(
                title: 'Tenant Rating',
                subtitle: 'Rate tenants based on payment reliability.',
                icon: Icons.star_outline,
              ),
              _FeatureItem(
                title: 'Tenant Profiles',
                subtitle: 'Keep contact and rental history in one place.',
                icon: Icons.groups_outlined,
              ),
              _FeatureItem(
                title: 'Income Overview',
                subtitle: 'Review rental income and outstanding months.',
                icon: Icons.account_balance_wallet_outlined,
              ),
            ],
          ),
          const SizedBox(height: 20),
          const _HighlightStrip(
            title: 'Landlord Snapshot',
            items: [
              _MiniStat(label: 'Collected this month', value: 'RM 9,200'),
              _MiniStat(label: 'Late tenants', value: '2'),
              _MiniStat(label: 'Avg rating', value: '4.6 / 5'),
              _MiniStat(label: 'Units occupied', value: '12 / 13'),
            ],
          ),
          const SizedBox(height: 20),
          const _FeatureGrid(
            title: 'Suggested Next Steps',
            items: [
              _FeatureItem(
                title: 'Review Payments',
                subtitle: 'See who paid on time and who is late.',
                icon: Icons.receipt_long_outlined,
              ),
              _FeatureItem(
                title: 'Rate Tenants',
                subtitle: 'Leave a score after each payment cycle.',
                icon: Icons.star_outline,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FeatureGrid extends StatelessWidget {
  const _FeatureGrid({required this.title, required this.items});

  final String title;
  final List<_FeatureItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: items,
        ),
      ],
    );
  }
}

class _FeatureItem extends StatelessWidget {
  const _FeatureItem({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

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
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 10),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text(subtitle, style: const TextStyle(color: Colors.black54)),
            ],
          ),
        ),
      ),
    );
  }
}

class _HighlightStrip extends StatelessWidget {
  const _HighlightStrip({required this.title, required this.items});

  final String title;
  final List<_MiniStat> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: items,
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 170,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.black54)),
              const SizedBox(height: 6),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}
