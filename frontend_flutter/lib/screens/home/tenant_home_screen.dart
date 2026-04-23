import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../widgets/common/primary_button.dart';
import '../../widgets/layout/app_scaffold.dart';

class TenantHomeScreen extends StatelessWidget {
  const TenantHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Tenant Dashboard',
      child: ListView(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome, Tenant',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Track rent, pay on time, and keep your profile ready for future rentals.',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    SizedBox(
                      width: 160,
                      child: PrimaryButton(
                        label: 'Pay Rent',
                        onPressed: () => context.go('/payments'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 160,
                      child: OutlinedButton(
                        onPressed: () => context.go('/profile'),
                        child: const Text('View Profile'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const _FeatureGrid(
            title: 'Tenant Tools',
            items: [
              _FeatureItem(
                title: 'Rent Payment',
                subtitle: 'Submit rent and track monthly status.',
                icon: Icons.payment_outlined,
              ),
              _FeatureItem(
                title: 'Payment History',
                subtitle: 'See on-time streaks and late payments.',
                icon: Icons.receipt_long_outlined,
              ),
              _FeatureItem(
                title: 'Profile',
                subtitle: 'Keep your rental preferences updated.',
                icon: Icons.person_outline,
              ),
              _FeatureItem(
                title: 'Rent Analysis',
                subtitle: 'Check whether the rent is worth it.',
                icon: Icons.analytics_outlined,
              ),
            ],
          ),
          const SizedBox(height: 20),
          const _HighlightStrip(
            title: 'Tenant Snapshot',
            items: [
              _MiniStat(label: 'Next due', value: '05 May'),
              _MiniStat(label: 'On-time streak', value: '8 mo'),
              _MiniStat(label: 'Saved deals', value: '14'),
              _MiniStat(label: 'Preferred area', value: 'Klang Valley'),
            ],
          ),
          const SizedBox(height: 20),
          const _FeatureGrid(
            title: 'Suggested Next Steps',
            items: [
              _FeatureItem(
                title: 'Pay Rent Now',
                subtitle: 'Submit your monthly payment in one tap.',
                icon: Icons.payments_outlined,
              ),
              _FeatureItem(
                title: 'Review Preferences',
                subtitle: 'Keep beds, pets, and amenities updated.',
                icon: Icons.tune_outlined,
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
