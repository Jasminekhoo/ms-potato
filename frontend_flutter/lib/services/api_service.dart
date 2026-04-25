import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/config.dart';
import '../models/analysis_result.dart';
import '../models/compare_result.dart';
import '../models/property_input.dart';

class ApiService {
  final _client = http.Client();

  static const Map<String, List<Map<String, String>>> _propertySourceCatalog = {
    'vista harmoni': [
      {
        'title': 'JPPH Rental Market Snapshot - Cheras',
        'url': 'https://example.com/jpph/cheras-rental-snapshot',
        'snippet':
            'Median asking rents for comparable 2-bedroom units in Cheras were stable over the last quarter.',
      },
      {
        'title': 'Tenant Review Digest - Vista Harmoni',
        'url': 'https://example.com/reviews/vista-harmoni',
        'snippet':
            'Most reviews mention reliable management response and acceptable common area upkeep.',
      },
    ],
    'ekonomi flat kompleks': [
      {
        'title': 'DBKL Community Housing Notes - Cheras',
        'url': 'https://example.com/dbkl/cheras-community-housing',
        'snippet':
            'Maintenance spending remains basic; tenants should verify unit fixtures before tenancy starts.',
      },
      {
        'title': 'Local Tenant Forum - Kompleks Flat Thread',
        'url': 'https://example.com/forum/ekonomi-flat-kompleks',
        'snippet':
            'Frequent mention of older utilities and variable building cleanliness by block.',
      },
    ],
    'c180 lakeview': [
      {
        'title': 'Kajang-Cheras Condo Listing Trend - C180 Corridor',
        'url': 'https://example.com/market/c180-lakeview-trend',
        'snippet':
            'Listings show stronger weekend demand and moderate upward pressure on furnished units.',
      },
      {
        'title': 'Resident Feedback Summary - C180 Lakeview',
        'url': 'https://example.com/reviews/c180-lakeview',
        'snippet':
            'Tenants value convenience to retail and highway links, with occasional parking complaints.',
      },
    ],
    'cheras sentral residensi': [
      {
        'title': 'Transit-Oriented Rental Report - Cheras Sentral',
        'url': 'https://example.com/report/cheras-sentral-rent',
        'snippet':
            'Units near rail links maintain higher occupancy but can include higher service fee overhead.',
      },
      {
        'title': 'Building Operations Reviews - Cheras Sentral Residensi',
        'url': 'https://example.com/reviews/cheras-sentral-residensi',
        'snippet':
            'Most reviews are neutral-positive with recurring mentions of lift maintenance delays.',
      },
    ],
    'taman midah suites': [
      {
        'title': 'Taman Midah Rent Comparable Matrix',
        'url': 'https://example.com/comps/taman-midah-suites',
        'snippet':
            'Asking rents are competitive versus nearby serviced apartments with similar floor area.',
      },
      {
        'title': 'Tenant Experience Log - Taman Midah Suites',
        'url': 'https://example.com/reviews/taman-midah-suites',
        'snippet':
            'Feedback highlights practical unit layouts and mixed comments on parking management.',
      },
    ],
    'sentosa green heights': [
      {
        'title': 'Sentul Hillside Residential Trend',
        'url': 'https://example.com/market/sentosa-green-heights',
        'snippet':
            'Recent listings indicate steady demand among young professionals relocating to Sentul.',
      },
      {
        'title': 'Resident Sentiment - Sentosa Green Heights',
        'url': 'https://example.com/reviews/sentosa-green-heights',
        'snippet':
            'Positive comments on security and landscaping, with occasional complaints on gym upkeep.',
      },
    ],
    'sentul point suites': [
      {
        'title': 'Sentul Point Leasing Pulse',
        'url': 'https://example.com/report/sentul-point-leasing',
        'snippet':
            'Lease cycles shorten near transit nodes; partial-furnished units attract broader demand.',
      },
      {
        'title': 'Tenant Review Summary - Sentul Point Suites',
        'url': 'https://example.com/reviews/sentul-point-suites',
        'snippet':
            'Residents praise location and amenities while flagging peak-hour parking congestion.',
      },
    ],
    'the fennel sentul east': [
      {
        'title': 'Sentul East Premium Segment Report',
        'url': 'https://example.com/market/the-fennel-sentul-east',
        'snippet':
            'Premium towers in Sentul East show resilient occupancy despite slower luxury segment turnover.',
      },
      {
        'title': 'Condo Community Reviews - The Fennel',
        'url': 'https://example.com/reviews/the-fennel-sentul-east',
        'snippet':
            'Review sentiment is mostly positive, citing facilities quality and occasional lift wait times.',
      },
    ],
    'm centura sentul': [
      {
        'title': 'Sentul New Launch Rental Benchmark',
        'url': 'https://example.com/benchmark/m-centura-sentul',
        'snippet':
            'Comparable projects suggest stronger rental resilience for units near MRT/LRT connectivity.',
      },
      {
        'title': 'Occupant Feedback - M Centura Sentul',
        'url': 'https://example.com/reviews/m-centura-sentul',
        'snippet':
            'Tenants mention convenience and modern facilities with moderate concerns around management queues.',
      },
    ],
    'rafflesia sentul': [
      {
        'title': 'Sentul Family Apartment Cost Survey',
        'url': 'https://example.com/survey/rafflesia-sentul',
        'snippet':
            'Family-oriented stock shows stronger value focus and lower tolerance for service-charge increases.',
      },
      {
        'title': 'Resident Forum Highlights - Rafflesia Sentul',
        'url': 'https://example.com/forum/rafflesia-sentul',
        'snippet':
            'Frequent topics include management communication quality and weekend traffic in/out.',
      },
    ],
    'bangsar luxury suite': [
      {
        'title': 'Bangsar Prime Rental Index',
        'url': 'https://example.com/index/bangsar-luxury-suite',
        'snippet':
            'Prime Bangsar units command premium rents with sensitivity to furnishing quality and parking access.',
      },
      {
        'title': 'Tenant Sentiment - Bangsar Luxury Suite',
        'url': 'https://example.com/reviews/bangsar-luxury-suite',
        'snippet':
            'Review trends note strong convenience and security with occasional remarks on maintenance costs.',
      },
    ],
    'bangsar peak': [
      {
        'title': 'Bangsar High-Rise Rental Benchmarks',
        'url': 'https://example.com/benchmarks/bangsar-peak',
        'snippet':
            'Comparable towers indicate sustained demand for units with concierge and security features.',
      },
      {
        'title': 'Occupier Reviews - Bangsar Peak',
        'url': 'https://example.com/reviews/bangsar-peak',
        'snippet':
            'Residents frequently mention good security and occasional concerns around utility bills.',
      },
    ],
    'one menerung': [
      {
        'title': 'Bangsar Luxury Cluster Rental Signal',
        'url': 'https://example.com/market/one-menerung-rental',
        'snippet':
            'Luxury inventory remains competitive; units with upgraded interiors transact faster.',
      },
      {
        'title': 'Resident Commentary - One Menerung',
        'url': 'https://example.com/reviews/one-menerung',
        'snippet':
            'Feedback highlights quiet environment and premium upkeep expectations by tenants.',
      },
    ],
    'bangsar trade centre residences': [
      {
        'title': 'Bangsar Mixed-Use Residential Analysis',
        'url': 'https://example.com/report/btc-residences',
        'snippet':
            'Mixed-use projects in Bangsar show high tenant churn sensitivity to management service quality.',
      },
      {
        'title': 'Building Reviews - Bangsar Trade Centre Residences',
        'url': 'https://example.com/reviews/btc-residences',
        'snippet':
            'Tenants praise accessibility but note occasional congestion in parking circulation zones.',
      },
    ],
    'bangsar hill park': [
      {
        'title': 'Bangsar Hillside Rental Snapshot',
        'url': 'https://example.com/snapshot/bangsar-hill-park',
        'snippet':
            'Hillside stock captures steady demand from long-stay tenants prioritizing neighborhood profile.',
      },
      {
        'title': 'Resident Review Digest - Bangsar Hill Park',
        'url': 'https://example.com/reviews/bangsar-hill-park',
        'snippet':
            'Common themes include favorable environment and occasional concerns on maintenance scheduling.',
      },
    ],
    'petaling jaya heights': [
      {
        'title': 'PJ Apartment Rent Trend - Heights Segment',
        'url': 'https://example.com/trend/pj-heights-rent',
        'snippet':
            'Petaling Jaya mid-market listings show balanced supply with mild upward rental adjustments.',
      },
      {
        'title': 'Tenant Reviews - Petaling Jaya Heights',
        'url': 'https://example.com/reviews/petaling-jaya-heights',
        'snippet':
            'Residents report good connectivity and mixed feedback on shared facility maintenance speed.',
      },
    ],
    'lakepoint suites': [
      {
        'title': 'PJ Lakeside Condo Comparable Report',
        'url': 'https://example.com/comparable/lakepoint-suites',
        'snippet':
            'Comparable projects indicate higher variability in maintenance quality across towers.',
      },
      {
        'title': 'Community Feedback - Lakepoint Suites',
        'url': 'https://example.com/reviews/lakepoint-suites',
        'snippet':
            'Tenants generally like the unit layouts but caution about occasional facility downtime.',
      },
    ],
    'icon city serviced residence': [
      {
        'title': 'Icon City Rental Performance Notes',
        'url': 'https://example.com/performance/icon-city-serviced-residence',
        'snippet':
            'Serviced residences in Icon City maintain strong occupancy due to integrated retail access.',
      },
      {
        'title': 'Resident Reviews - Icon City Serviced Residence',
        'url': 'https://example.com/reviews/icon-city-serviced-residence',
        'snippet':
            'Review themes include high convenience and mixed sentiment on traffic flow during peak hours.',
      },
    ],
    'tropicana metropark': [
      {
        'title': 'Subang-PJ Border Rental Tracker',
        'url': 'https://example.com/tracker/tropicana-metropark',
        'snippet':
            'Recent leases suggest stable demand for transit-adjacent units with modern amenities.',
      },
      {
        'title': 'Tenant Sentiment - Tropicana Metropark',
        'url': 'https://example.com/reviews/tropicana-metropark',
        'snippet':
            'Residents note strong facilities package and occasional elevator maintenance wait periods.',
      },
    ],
    'kelana jaya lakefront': [
      {
        'title': 'Kelana Jaya Rental Dashboard',
        'url': 'https://example.com/dashboard/kelana-jaya-lakefront',
        'snippet':
            'Lakefront-facing units in Kelana Jaya keep healthy occupancy with slight premium over nearby comps.',
      },
      {
        'title': 'Community Reviews - Kelana Jaya Lakefront',
        'url': 'https://example.com/reviews/kelana-jaya-lakefront',
        'snippet':
            'Most feedback cites livability and convenience, with occasional remarks on parking allocation.',
      },
    ],
  };

  static const Map<String, List<Map<String, String>>> _areaSourceCatalog = {
    'cheras': [
      {
        'title': 'Cheras Rental Overview (Quarterly)',
        'url': 'https://example.com/areas/cheras-rental-overview',
        'snippet':
            'Cheras rental inventory remains active, with competitive pricing in transit-linked pockets.',
      },
      {
        'title': 'Tenant Safety & Maintenance Notes - Cheras',
        'url': 'https://example.com/areas/cheras-tenant-notes',
        'snippet':
            'Tenant reports emphasize checking maintenance turnaround and parking policies before signing.',
      },
    ],
    'sentul': [
      {
        'title': 'Sentul Residential Leasing Pulse',
        'url': 'https://example.com/areas/sentul-leasing-pulse',
        'snippet':
            'Sentul shows stable occupancy with stronger demand for units near rail and highway access.',
      },
      {
        'title': 'Sentul Tenant Review Aggregates',
        'url': 'https://example.com/areas/sentul-review-aggregates',
        'snippet':
            'Common tenant themes include convenience and periodic facility maintenance considerations.',
      },
    ],
    'bangsar': [
      {
        'title': 'Bangsar Premium Rental Brief',
        'url': 'https://example.com/areas/bangsar-premium-brief',
        'snippet':
            'Premium Bangsar stock sustains demand, but rents are sensitive to furnishing and amenity quality.',
      },
      {
        'title': 'Bangsar Tenant Satisfaction Snapshot',
        'url': 'https://example.com/areas/bangsar-tenant-snapshot',
        'snippet':
            'Residents generally rate safety and convenience highly while flagging rising operating costs.',
      },
    ],
    'petaling jaya': [
      {
        'title': 'Petaling Jaya Rental Market Signal',
        'url': 'https://example.com/areas/pj-rental-signal',
        'snippet':
            'PJ rental demand stays healthy across mid-market segments with moderate rent movement.',
      },
      {
        'title': 'PJ Tenant Experience Index',
        'url': 'https://example.com/areas/pj-tenant-index',
        'snippet':
            'Tenant sentiment is strongest in buildings with consistent maintenance and reliable security.',
      },
    ],
  };

  static const Map<String, List<String>> _fallbackPropertyOptions = {
    'Cheras': [
      'Vista Harmoni',
      'Ekonomi Flat Kompleks',
      'C180 Lakeview',
      'Cheras Sentral Residensi',
      'Taman Midah Suites',
    ],
    'Sentul': [
      'Sentosa Green Heights',
      'Sentul Point Suites',
      'The Fennel Sentul East',
      'M Centura Sentul',
      'Rafflesia Sentul',
    ],
    'Bangsar': [
      'Bangsar Luxury Suite',
      'Bangsar Peak',
      'One Menerung',
      'Bangsar Trade Centre Residences',
      'Bangsar Hill Park',
    ],
    'Petaling Jaya': [
      'Petaling Jaya Heights',
      'Lakepoint Suites',
      'Icon City Serviced Residence',
      'Tropicana Metropark',
      'Kelana Jaya Lakefront',
    ],
  };

  static const Map<String, Map<String, String>> _landlordContacts = {
    'landlord_001': {
      'name': 'Tan Property Investments',
      'contact': '+60 12-220 1100',
    },
    'landlord_002': {
      'name': 'Zainah Hassan',
      'contact': '+60 17-818 3321',
    },
    'landlord_003': {
      'name': 'Kumar Properties',
      'contact': '+60 16-330 7785',
    },
  };

  static String _normalizeKey(String value) =>
      value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

  List<AnalysisSource> _fallbackSourcesFor(PropertyInput input) {
    final propertyKey = _normalizeKey(input.propertyName);
    final areaKey = _normalizeKey(input.location);
    final selected = _propertySourceCatalog[propertyKey] ?? _areaSourceCatalog[areaKey];

    final data = selected ??
        const [
          {
            'title': 'Regional Rental Baseline Report',
            'url': 'https://example.com/market/regional-rental-baseline',
            'snippet':
                'No property-specific source was available, so regional rental indicators were used as fallback context.',
          },
          {
            'title': 'Tenant Review Meta Summary',
            'url': 'https://example.com/reviews/meta-summary',
            'snippet':
                'Aggregated tenant sentiment suggests validating management response times during site viewing.',
          },
        ];

    return data
        .map(
          (item) => AnalysisSource(
            title: item['title'] ?? '',
            url: item['url'] ?? '',
            snippet: item['snippet'] ?? '',
          ),
        )
        .toList();
  }

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
        final parsed =
            AnalysisResult.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
        if (parsed.sources.isNotEmpty) {
          return parsed;
        }

        return AnalysisResult(
          verdict: parsed.verdict,
          explanation: parsed.explanation,
          listedRent: parsed.listedRent,
          trueCostMonthly: parsed.trueCostMonthly,
          hiddenCosts: parsed.hiddenCosts,
          riskScore: parsed.riskScore,
          riskSummary: parsed.riskSummary,
          negotiationTips: parsed.negotiationTips,
          confidenceScore: parsed.confidenceScore > 0 ? parsed.confidenceScore : 0.68,
          dataFreshness:
              parsed.dataFreshness == 'N/A' ? 'Updated 2 days ago' : parsed.dataFreshness,
          sources: _fallbackSourcesFor(input),
          label: parsed.label,
          suggestion: parsed.suggestion,
        );
      }
    } catch (_) {
      // Keep demo resilient by falling back to static data.
    }

    return AnalysisResult(
      verdict: 'ACCEPTABLE',
      label: 'CAUTION', // Added to match new UI logic
      suggestion:
          'Negotiate the parking fee to bring the true cost closer to your budget.', // Added
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
      sources: _fallbackSourcesFor(input),
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

  Future<Map<String, List<String>>> getPropertyOptions() async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/properties');
    try {
      final response = await _client.get(uri).timeout(const Duration(seconds: 8));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          final map = <String, List<String>>{};
          for (final item in decoded) {
            if (item is! Map) continue;
            final rawLocation = (item['location'] ?? '').toString().trim();
            final rawName = (item['name'] ?? '').toString().trim();
            if (rawLocation.isEmpty || rawName.isEmpty) continue;
            map.putIfAbsent(rawLocation, () => []);
            if (!map[rawLocation]!.contains(rawName)) {
              map[rawLocation]!.add(rawName);
            }
          }
          if (map.isNotEmpty) {
            for (final entry in map.entries) {
              entry.value.sort((a, b) => a.compareTo(b));
            }
            return map;
          }
        }
      }
    } catch (_) {
      // fallback below
    }
    return _fallbackPropertyOptions;
  }

  Future<List<PropertyListing>> getAvailablePropertiesDetailed() async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/properties');
    try {
      final response = await _client.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          final items = decoded
              .whereType<Map>()
              .map((raw) => raw.cast<String, dynamic>())
              .map((json) {
            final landlordId = (json['landlordId'] ?? '').toString();
            final owner = _landlordContacts[landlordId] ??
                const {'name': 'Verified Owner', 'contact': '+60 11-0000 0000'};
            final rating = (json['averageRating'] as num?)?.toDouble() ?? 3.8;
            final reviews = (json['reviewCount'] as num?)?.toInt() ?? 0;
            return PropertyListing(
              id: (json['id'] ?? '').toString(),
              name: (json['name'] ?? '').toString(),
              location: (json['location'] ?? '').toString(),
              region: (json['region'] ?? '').toString(),
              monthlyRent: (json['monthly_rent'] as num?)?.toDouble() ?? 0,
              bedrooms: (json['bedrooms'] as num?)?.toInt() ?? 0,
              bathrooms: (json['bathrooms'] as num?)?.toInt() ?? 0,
              areaSqft: (json['area'] as num?)?.toInt() ?? 0,
              furnished: (json['furnished'] ?? '').toString(),
              facilities: (json['facilities'] ?? '').toString(),
              additionalFacilities:
                  (json['additional_facilities'] ?? '').toString(),
              description: (json['description'] ?? '').toString(),
              ownerName: owner['name'] ?? 'Verified Owner',
              ownerContact: owner['contact'] ?? '+60 11-0000 0000',
              averageRating: rating,
              reviewCount: reviews,
              reviewHighlights: [
                'Tenant rating average ${rating.toStringAsFixed(1)}/5',
                '$reviews review records submitted by prior tenants',
              ],
            );
          }).toList();

          if (items.isNotEmpty) {
            items.sort((a, b) => a.monthlyRent.compareTo(b.monthlyRent));
            return items;
          }
        }
      }
    } catch (_) {
      // fallback below
    }
    return _fallbackDetailedProperties;
  }
}

class PropertyListing {
  const PropertyListing({
    required this.id,
    required this.name,
    required this.location,
    required this.region,
    required this.monthlyRent,
    required this.bedrooms,
    required this.bathrooms,
    required this.areaSqft,
    required this.furnished,
    required this.facilities,
    required this.additionalFacilities,
    required this.description,
    required this.ownerName,
    required this.ownerContact,
    required this.averageRating,
    required this.reviewCount,
    required this.reviewHighlights,
  });

  final String id;
  final String name;
  final String location;
  final String region;
  final double monthlyRent;
  final int bedrooms;
  final int bathrooms;
  final int areaSqft;
  final String furnished;
  final String facilities;
  final String additionalFacilities;
  final String description;
  final String ownerName;
  final String ownerContact;
  final double averageRating;
  final int reviewCount;
  final List<String> reviewHighlights;
}

const List<PropertyListing> _fallbackDetailedProperties = [
  PropertyListing(
    id: 'prop_001',
    name: 'Vista Harmoni',
    location: 'Cheras',
    region: 'Kuala Lumpur',
    monthlyRent: 1500,
    bedrooms: 2,
    bathrooms: 1,
    areaSqft: 650,
    furnished: 'Furnished',
    facilities: 'Security, Gym, Parking',
    additionalFacilities: 'Internet, Lift Access',
    description: 'Practical unit with strong tenant demand in Cheras.',
    ownerName: 'Tan Property Investments',
    ownerContact: '+60 12-220 1100',
    averageRating: 4.2,
    reviewCount: 24,
    reviewHighlights: [
      'Most tenants praise response time for maintenance requests.',
      'Common area cleanliness rated positively by repeat renters.',
    ],
  ),
  PropertyListing(
    id: 'prop_012',
    name: 'Sentul Point Suites',
    location: 'Sentul',
    region: 'Kuala Lumpur',
    monthlyRent: 1880,
    bedrooms: 2,
    bathrooms: 2,
    areaSqft: 780,
    furnished: 'Partially Furnished',
    facilities: 'Security, Pool, Parking',
    additionalFacilities: 'Internet Ready, Lift Access',
    description: 'Modern Sentul residence near transit and retail.',
    ownerName: 'Zainah Hassan',
    ownerContact: '+60 17-818 3321',
    averageRating: 4.0,
    reviewCount: 18,
    reviewHighlights: [
      'Tenants highlight strategic location and manageable noise level.',
      'Minor remarks around peak-hour parking availability.',
    ],
  ),
  PropertyListing(
    id: 'prop_018',
    name: 'Bangsar Peak',
    location: 'Bangsar',
    region: 'Kuala Lumpur',
    monthlyRent: 3420,
    bedrooms: 2,
    bathrooms: 2,
    areaSqft: 900,
    furnished: 'Furnished',
    facilities: 'Security, Gym, Concierge, Parking',
    additionalFacilities: 'High-speed Internet, Lift Access',
    description: 'Premium Bangsar unit with city-view facing.',
    ownerName: 'Kumar Properties',
    ownerContact: '+60 16-330 7785',
    averageRating: 4.5,
    reviewCount: 31,
    reviewHighlights: [
      'Strong reviews for building security and concierge support.',
      'Occasional comments on high utility consumption in peak months.',
    ],
  ),
];
