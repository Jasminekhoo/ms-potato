import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils.dart';
import '../../services/api_service.dart';
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
                path: '/payments',
              ),
              _FeatureItem(
                title: 'Payment History',
                subtitle: 'See on-time streaks and late payments.',
                icon: Icons.receipt_long_outlined,
                path: '/payments',
              ),
              _FeatureItem(
                title: 'Profile',
                subtitle: 'Keep your rental preferences updated.',
                icon: Icons.person_outline,
                path: '/profile',
              ),
              _FeatureItem(
                title: 'Rent Analysis',
                subtitle: 'Check whether the rent is worth it.',
                icon: Icons.analytics_outlined,
                path: '/input',
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
          const _AvailablePropertiesSection(),
          const SizedBox(height: 20),
          const _FeatureGrid(
            title: 'Suggested Next Steps',
            items: [
              _FeatureItem(
                title: 'Pay Rent Now',
                subtitle: 'Submit your monthly payment in one tap.',
                icon: Icons.payments_outlined,
                path: '/payments',
              ),
              _FeatureItem(
                title: 'Review Preferences',
                subtitle: 'Keep beds, pets, and amenities updated.',
                icon: Icons.tune_outlined,
                path: '/profile',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AvailablePropertiesSection extends StatefulWidget {
  const _AvailablePropertiesSection();

  @override
  State<_AvailablePropertiesSection> createState() =>
      _AvailablePropertiesSectionState();
}

class _AvailablePropertiesSectionState extends State<_AvailablePropertiesSection> {
  late final Future<List<PropertyListing>> _propertiesFuture;
  final _searchCtrl = TextEditingController();
  String _areaFilter = 'All';
  double _maxBudget = 6000;
  int _visibleCount = 6;

  @override
  void initState() {
    super.initState();
    _propertiesFuture = ApiService().getAvailablePropertiesDetailed();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PropertyListing>>(
      future: _propertiesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Available Properties',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  SizedBox(height: 12),
                  LinearProgressIndicator(minHeight: 2),
                ],
              ),
            ),
          );
        }

        final properties = snapshot.data ?? const <PropertyListing>[];
        if (properties.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('No available properties found right now.'),
            ),
          );
        }

        final areas = <String>{'All', ...properties.map((e) => e.location)};
        final query = _searchCtrl.text.trim().toLowerCase();
        final filtered = properties.where((property) {
          final areaMatch =
              _areaFilter == 'All' || property.location == _areaFilter;
          final budgetMatch = property.monthlyRent <= _maxBudget;
          final queryMatch = query.isEmpty ||
              property.name.toLowerCase().contains(query) ||
              property.location.toLowerCase().contains(query) ||
              property.facilities.toLowerCase().contains(query);
          return areaMatch && budgetMatch && queryMatch;
        }).toList();
        final visible = filtered.take(_visibleCount).toList();
        final canShowMore = visible.length < filtered.length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Available Properties',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Complete mock listing with facilities, pricing, review sentiment, and owner contact.',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Search by property, area, or facility',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (_) => setState(() {
                            _visibleCount = 6;
                          }),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _areaFilter,
                            items: areas
                                .map((area) => DropdownMenuItem(
                                      value: area,
                                      child: Text(area),
                                    ))
                                .toList(),
                            decoration: const InputDecoration(labelText: 'Area'),
                            onChanged: (value) {
                              if (value == null) return;
                              setState(() {
                                _areaFilter = value;
                                _visibleCount = 6;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Max Budget: ${Currency.rm(_maxBudget)}',
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              Slider(
                                value: _maxBudget,
                                min: 1000,
                                max: 6000,
                                divisions: 25,
                                label: Currency.rm(_maxBudget),
                                onChanged: (value) {
                                  setState(() {
                                    _maxBudget = value;
                                    _visibleCount = 6;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (filtered.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('No properties matched your search/filter.'),
              )
            else
              Wrap(
              spacing: 12,
              runSpacing: 12,
              children: visible
                  .map((property) => _PropertyDetailCard(property: property))
                  .toList(),
            ),
            if (canShowMore)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _visibleCount += 6;
                      });
                    },
                    icon: const Icon(Icons.expand_more),
                    label: Text('Show more (${filtered.length - visible.length} left)'),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _PropertyDetailCard extends StatelessWidget {
  const _PropertyDetailCard({required this.property});

  final PropertyListing property;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 340,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                property.name,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
              ),
              const SizedBox(height: 4),
              Text(
                '${property.location}, ${property.region}',
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _InfoChip(label: 'Rent', value: '${Currency.rm(property.monthlyRent)}/mo'),
                  _InfoChip(label: 'Beds/Baths', value: '${property.bedrooms}/${property.bathrooms}'),
                  _InfoChip(label: 'Area', value: '${property.areaSqft} sqft'),
                  _InfoChip(label: 'Furnished', value: property.furnished),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                property.description,
                style: const TextStyle(color: Colors.black87),
              ),
              const SizedBox(height: 10),
              Text('Facilities: ${property.facilities}'),
              const SizedBox(height: 4),
              Text('More: ${property.additionalFacilities}'),
              const SizedBox(height: 10),
              Text(
                'Reviews ${property.averageRating.toStringAsFixed(1)}/5 (${property.reviewCount})',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              ...property.reviewHighlights.take(2).map(
                    (line) => Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text('• $line', style: const TextStyle(color: Colors.black87)),
                    ),
                  ),
              const SizedBox(height: 10),
              Text(
                'Owner: ${property.ownerName}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Text('Contact: ${property.ownerContact}'),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Contact request sent to ${property.ownerName}.',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.call_outlined, size: 18),
                  label: const Text('Contact Owner'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text('$label: $value'),
      padding: const EdgeInsets.symmetric(horizontal: 6),
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
    required this.path,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String path;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => context.go(path),
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
