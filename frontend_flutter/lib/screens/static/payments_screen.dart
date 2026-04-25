import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

import '../../widgets/layout/app_scaffold.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  late final Future<String> _roleFuture;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _roleFuture = user == null ? Future.value('guest') : _resolveRole(user.uid);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Payments',
      child: FutureBuilder<String>(
        future: _roleFuture,
        builder: (context, snapshot) {
          final role = snapshot.data ?? 'guest';
          final user = FirebaseAuth.instance.currentUser;

          if (user == null) {
            return _GuestPrompt(onLogin: () => context.go('/'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final isLandlord = role == 'landlord';
          return ListView(
            children: [
              _OverviewCard(role: role),
              const SizedBox(height: 12),
              if (!isLandlord) ...[
                const _TenantPayRentCard(),
                const SizedBox(height: 12),
                const _TenantPaymentHistoryCard(),
                const SizedBox(height: 12),
                const _TenantSelfRatingCard(),
              ] else ...[
                const _LandlordCollectionsCard(),
                const SizedBox(height: 12),
                const _LandlordTenantStatusCard(),
                const SizedBox(height: 12),
                const _LandlordRatingCard(),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _GuestPrompt extends StatelessWidget {
  const _GuestPrompt({required this.onLogin});

  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Please sign in from Home to view payments.'),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: onLogin,
                  child: const Text('Go to Home'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({required this.role});

  final String role;

  @override
  Widget build(BuildContext context) {
    final isLandlord = role == 'landlord';
    if (isLandlord) {
      return const _LandlordOverviewCard();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isLandlord
                  ? 'Landlord Payment Overview'
                  : 'Tenant Payment Overview',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 10),
            Text(
              'Track whether your rent was paid on time and submit your monthly payment.',
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: const [
                _StatusChip(label: 'On-time streak', value: '8 months'),
                _StatusChip(label: 'Late payments', value: '1 this year'),
                _StatusChip(label: 'Current status', value: 'Good standing'),
                _StatusChip(label: 'Next due date', value: '05 May 2026'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LandlordOverviewCard extends StatelessWidget {
  const _LandlordOverviewCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Landlord Payment Overview',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Quick summary of landlord payment status.',
            ),
            const SizedBox(height: 16),
            const Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _StatusChip(label: 'On-time tenants', value: '10'),
                _StatusChip(label: 'Late tenants', value: '2'),
                _StatusChip(label: 'Pending tenants', value: '3'),
                _StatusChip(label: 'Outstanding rent', value: 'RM 3,600'),
                _StatusChip(label: 'Avg tenant rating', value: '4.6 / 5'),
                _StatusChip(label: 'Rated tenants', value: '7'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TenantPayRentCard extends StatefulWidget {
  const _TenantPayRentCard();

  @override
  State<_TenantPayRentCard> createState() => _TenantPayRentCardState();
}

class _TenantPayRentCardState extends State<_TenantPayRentCard> {
  final _amountController = TextEditingController(text: '1800');
  final _referenceController = TextEditingController();
  String _method = 'Online Banking';
  bool _confirmedTerms = false;
  bool _isProcessing = false;

  @override
  void dispose() {
    _amountController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pay Rent',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Rent amount',
                prefixText: 'RM ',
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _method,
              decoration: const InputDecoration(labelText: 'Payment method'),
              items: const [
                DropdownMenuItem(
                    value: 'Online Banking', child: Text('Online Banking')),
                DropdownMenuItem(
                    value: 'Credit / Debit Card',
                    child: Text('Credit / Debit Card')),
                DropdownMenuItem(value: 'eWallet', child: Text('eWallet')),
                DropdownMenuItem(value: 'Cash', child: Text('Cash')),
              ],
              onChanged: _isProcessing
                  ? null
                  : (value) {
                      if (value != null) {
                        setState(() {
                          _method = value;
                        });
                      }
                    },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _referenceController,
              decoration: const InputDecoration(
                labelText: 'Transaction reference / note',
              ),
            ),
            const SizedBox(height: 12),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _confirmedTerms,
              onChanged: _isProcessing
                  ? null
                  : (value) {
                      setState(() {
                        _confirmedTerms = value ?? false;
                      });
                    },
              title: const Text('I confirm this month rent amount and payment details are correct.'),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                FilledButton.icon(
                  onPressed: (_isProcessing || !_confirmedTerms)
                      ? null
                      : _submitPayment,
                  icon: const Icon(Icons.payment_outlined),
                  label:
                      Text(_isProcessing ? 'Processing...' : 'Confirm & Pay'),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: _isProcessing
                      ? null
                      : () {
                          setState(() {
                            _amountController.text = '1800';
                            _referenceController.clear();
                            _method = 'Online Banking';
                            _confirmedTerms = false;
                          });
                        },
                  child: const Text('Reset'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Payments are stored in the rent_payments collection.',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitPayment() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please login to submit payment.')),
        );
        return;
      }

      final amount = double.tryParse(_amountController.text.trim());
      if (amount == null || amount <= 0) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enter a valid rent amount.')),
        );
        return;
      }

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirm Rent Payment'),
          content: Text(
            'Pay RM ${amount.toStringAsFixed(0)} via $_method?\nReference: ${_referenceController.text.trim().isEmpty ? 'N/A' : _referenceController.text.trim()}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Confirm'),
            ),
          ],
        ),
      );
      if (confirmed != true) {
        return;
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final assignedLandlordId =
          (userDoc.data()?['assignedLandlordId'] as String?)?.trim();
      final landlordId =
          (assignedLandlordId != null && assignedLandlordId.isNotEmpty)
              ? assignedLandlordId
              : null;

      await FirebaseFirestore.instance.collection('rent_payments').add({
        'tenantId': user.uid,
        'landlordId': landlordId,
        'amount': amount,
        'method': _method,
        'reference': _referenceController.text.trim(),
        'status': 'submitted',
        'createdAt': FieldValue.serverTimestamp(),
        'createdAtLocal': DateTime.now().toIso8601String(),
        'source': 'tenant-payments-screen',
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment saved to the payments log.')),
      );
      setState(() {
        _confirmedTerms = false;
      });
    } on FirebaseException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save payment (${e.code}).')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
}

class _TenantPaymentHistoryCard extends StatelessWidget {
  const _TenantPaymentHistoryCard();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment History',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 10),
            const Text(
                'See whether your monthly rent was paid on time or late.'),
            const SizedBox(height: 14),
            Table(
              columnWidths: const {
                0: FlexColumnWidth(1.1),
                1: FlexColumnWidth(0.9),
                2: FlexColumnWidth(1.3),
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: const [
                TableRow(
                  children: [
                    _TableHeader('Date'),
                    _TableHeader('Amount'),
                    _TableHeader('Status'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('rent_payments')
                  .where('tenantId', isEqualTo: user.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (snapshot.hasError) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('Unable to load payment history.'),
                  );
                }

                final docs = snapshot.data?.docs.toList() ?? [];
                docs.sort((a, b) {
                  final aValue = _parseDateTime(a.data()['createdAtLocal']);
                  final bValue = _parseDateTime(b.data()['createdAtLocal']);
                  return bValue.compareTo(aValue);
                });

                if (docs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('No submitted payments yet.'),
                  );
                }

                return Column(
                  children: docs.map((doc) {
                    final data = doc.data();
                    final amount =
                        (data['amount'] as num?)?.toStringAsFixed(0) ?? '0';
                    final status = (data['status'] as String?) ?? 'submitted';
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 11,
                            child: Text(_formatDateLabel(
                                data['createdAtLocal'] as String?)),
                          ),
                          Expanded(flex: 9, child: Text('RM $amount')),
                          Expanded(
                            flex: 13,
                            child: Text(status.replaceAll('_', ' ')),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _TenantSelfRatingCard extends StatefulWidget {
  const _TenantSelfRatingCard();

  @override
  State<_TenantSelfRatingCard> createState() => _TenantSelfRatingCardState();
}

class _TenantSelfRatingCardState extends State<_TenantSelfRatingCard> {
  double _rating = 4.0;
  final _notesController = TextEditingController(
    text: 'Pays mostly on time, communicates early when delayed.',
  );

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tenant Notes',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 10),
            const Text(
                'Use this to keep personal payment notes and reminders.'),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Self score'),
                Expanded(
                  child: Slider(
                    value: _rating,
                    min: 1,
                    max: 5,
                    divisions: 4,
                    label: _rating.toStringAsFixed(1),
                    onChanged: (value) {
                      setState(() {
                        _rating = value;
                      });
                    },
                  ),
                ),
                Text(_rating.toStringAsFixed(1)),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Notes',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LandlordCollectionsCard extends StatelessWidget {
  const _LandlordCollectionsCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Collections Overview',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Latest collection summary for the landlord.',
            ),
            const SizedBox(height: 16),
            const Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _StatusChip(label: 'Received today', value: 'RM 9,200'),
                _StatusChip(label: 'Pending amount', value: 'RM 3,600'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LandlordTenantStatusCard extends StatelessWidget {
  const _LandlordTenantStatusCard();

  static const List<_TenantTrackerRow> _fallbackRows = [
    _TenantTrackerRow(
      tenantName: 'Ahmad Karim • Vista Harmoni',
      amountText: 'RM 2200',
      statusText: 'On Time',
    ),
    _TenantTrackerRow(
      tenantName: 'Siti Nurhayati • Sentul Point Suites',
      amountText: 'RM 1800',
      statusText: 'Pending',
    ),
    _TenantTrackerRow(
      tenantName: 'Rajesh Kumar • Ekonomi Flat Kompleks',
      amountText: 'RM 1650',
      statusText: 'Late',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .where('role', isEqualTo: 'tenant')
              .where('assignedLandlordId', isEqualTo: user.uid)
              .snapshots(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 18),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (userSnapshot.hasError) {
              return const Text('Unable to load tenant users.');
            }

            final tenantDocs = userSnapshot.data?.docs ?? [];

            return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('rent_payments')
                  .where('landlordId', isEqualTo: user.uid)
                  .snapshots(),
              builder: (context, paymentSnapshot) {
                if (paymentSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 18),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (paymentSnapshot.hasError) {
                  return const Text('Unable to load tenant payments.');
                }

                final paymentDocs = paymentSnapshot.data?.docs ?? [];

                return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('tenant_ratings')
                      .where('landlordId', isEqualTo: user.uid)
                      .snapshots(),
                  builder: (context, ratingSnapshot) {
                    final ratingDocs = ratingSnapshot.data?.docs ?? [];

                    final latestPaymentByTenant =
                        <String, Map<String, dynamic>>{};
                    for (final doc in paymentDocs) {
                      final data = doc.data();
                      final tenantId = (data['tenantId'] as String?)?.trim();
                      if (tenantId == null || tenantId.isEmpty) {
                        continue;
                      }
                      final candidateAt =
                          _parseDateTime(data['createdAtLocal']);
                      final existing = latestPaymentByTenant[tenantId];
                      final existingAt =
                          _parseDateTime(existing?['createdAtLocal']);
                      if (existing == null || candidateAt.isAfter(existingAt)) {
                        latestPaymentByTenant[tenantId] = data;
                      }
                    }

                    final latestRatingByTenant =
                        <String, Map<String, dynamic>>{};
                    for (final doc in ratingDocs) {
                      final data = doc.data();
                      final tenantId = (data['tenantId'] as String?)?.trim();
                      if (tenantId == null || tenantId.isEmpty) {
                        continue;
                      }
                      final candidateAt =
                          _parseDateTime(data['createdAtLocal']);
                      final existing = latestRatingByTenant[tenantId];
                      final existingAt =
                          _parseDateTime(existing?['createdAtLocal']);
                      if (existing == null || candidateAt.isAfter(existingAt)) {
                        latestRatingByTenant[tenantId] = data;
                      }
                    }

                    final rows = tenantDocs.map((tenantDoc) {
                      final tenantData = tenantDoc.data();
                      final tenantId = tenantDoc.id;
                      final name =
                          (tenantData['name'] as String?)?.trim().isNotEmpty ==
                                  true
                              ? (tenantData['name'] as String).trim()
                              : ((tenantData['email'] as String?)?.trim() ??
                                  tenantId);

                      final latestPayment = latestPaymentByTenant[tenantId];
                      final amount = latestPayment == null
                          ? '--'
                          : 'RM ${_asDouble(latestPayment['amount']).toStringAsFixed(0)}';

                      var status = latestPayment == null
                          ? 'No payment yet'
                          : _prettifyStatus(
                              (latestPayment['status'] as String?) ??
                                  'submitted',
                            );

                      final latestRating = latestRatingByTenant[tenantId];
                      if (latestRating != null) {
                        status =
                            '$status • Rated ${_asDouble(latestRating['rating']).toStringAsFixed(1)}/5';
                      }

                      return _TenantTrackerRow(
                        tenantName: name,
                        amountText: amount,
                        statusText: status,
                      );
                    }).toList();

                    final useFallbackRows = rows.isEmpty;
                    if (useFallbackRows) {
                      rows.addAll(_fallbackRows);
                    }

                    rows.sort((a, b) => a.tenantName.compareTo(b.tenantName));

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tenant Payment Tracker',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          useFallbackRows
                              ? 'Showing sample tracker rows because no assigned tenant records were found yet.'
                              : 'Track on-time, late, pending, and rating status from live records.',
                        ),
                        const SizedBox(height: 14),
                        ...rows.take(12).map(
                              (row) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  children: [
                                    Expanded(
                                        flex: 4, child: Text(row.tenantName)),
                                    Expanded(
                                        flex: 3, child: Text(row.amountText)),
                                    Expanded(
                                        flex: 5, child: Text(row.statusText)),
                                    FilledButton.tonal(
                                      onPressed: () {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                'Reminder sent to ${row.tenantName}.'),
                                          ),
                                        );
                                      },
                                      child: const Text('Remind'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                      ],
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _LandlordRatingCard extends StatefulWidget {
  const _LandlordRatingCard();

  @override
  State<_LandlordRatingCard> createState() => _LandlordRatingCardState();
}

class _LandlordRatingCardState extends State<_LandlordRatingCard> {
  static const List<_TenantOption> _sampleTenantOptions = [
    _TenantOption(id: 'sample_user_001', label: 'Ahmad Karim • Vista Harmoni'),
    _TenantOption(
      id: 'sample_user_002',
      label: 'Siti Nurhayati • Sentul Point Suites',
    ),
    _TenantOption(
      id: 'sample_user_003',
      label: 'Rajesh Kumar • Ekonomi Flat Kompleks',
    ),
  ];

  double _rating = 4.4;
  String? _selectedTenantId;
  String? _selectedTenantLabel;
  final _notesController = TextEditingController(
    text: 'Pays mostly on time, communicates early when delayed.',
  );

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rate Tenant',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 10),
            const Text('Landlords can rate tenants after payment cycles.'),
            const SizedBox(height: 12),
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where('role', isEqualTo: 'tenant')
                  .where(
                    'assignedLandlordId',
                    isEqualTo: FirebaseAuth.instance.currentUser?.uid,
                  )
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: LinearProgressIndicator(minHeight: 2),
                  );
                }

                if (snapshot.hasError) {
                  return const Text('Unable to load tenant list.');
                }

                final liveOptions = (snapshot.data?.docs ?? []).map((doc) {
                  final data = doc.data();
                  final name = (data['name'] as String?)?.trim();
                  final email = (data['email'] as String?)?.trim();
                  final label = (name != null && name.isNotEmpty)
                      ? name
                      : (email ?? doc.id);
                  return _TenantOption(id: doc.id, label: label);
                }).toList();

                final options = liveOptions.isNotEmpty
                    ? liveOptions
                    : _sampleTenantOptions;

                final hasSelected =
                    options.any((o) => o.id == _selectedTenantId);
                final selected =
                    hasSelected ? _selectedTenantId : options.first.id;
                if (!hasSelected) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!mounted) return;
                    setState(() {
                      _selectedTenantId = options.first.id;
                      _selectedTenantLabel = options.first.label;
                    });
                  });
                }

                return DropdownButtonFormField<String>(
                  value: selected,
                  decoration: const InputDecoration(
                    labelText: 'Select tenant',
                  ),
                  items: options
                      .map(
                        (option) => DropdownMenuItem(
                          value: option.id,
                          child: Text(option.label),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    final option = options.firstWhere((o) => o.id == value);
                    setState(() {
                      _selectedTenantId = option.id;
                      _selectedTenantLabel = option.label;
                    });
                  },
                );
              },
            ),
            if (FirebaseAuth.instance.currentUser != null)
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .where('role', isEqualTo: 'tenant')
                    .where(
                      'assignedLandlordId',
                      isEqualTo: FirebaseAuth.instance.currentUser?.uid,
                    )
                    .snapshots(),
                builder: (context, snapshot) {
                  final liveOptions = (snapshot.data?.docs ?? []).map((doc) {
                    final data = doc.data();
                    final name = (data['name'] as String?)?.trim();
                    final email = (data['email'] as String?)?.trim();
                    final label = (name != null && name.isNotEmpty)
                        ? name
                        : (email ?? doc.id);
                    return _TenantOption(id: doc.id, label: label);
                  }).toList();

                  if (liveOptions.isNotEmpty) {
                    return const SizedBox.shrink();
                  }

                  return const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      'No assigned tenants found yet, so sample tenants are shown for now.',
                      style: TextStyle(color: Colors.black54),
                    ),
                  );
                },
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Rating'),
                Expanded(
                  child: Slider(
                    value: _rating,
                    min: 1,
                    max: 5,
                    divisions: 4,
                    label: _rating.toStringAsFixed(1),
                    onChanged: (value) {
                      setState(() {
                        _rating = value;
                      });
                    },
                  ),
                ),
                Text(_rating.toStringAsFixed(1)),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Landlord notes',
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _selectedTenantId == null ? null : _saveRating,
              icon: const Icon(Icons.star_border),
              label: const Text('Save Rating'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveRating() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to save ratings.')),
      );
      return;
    }

    if (_selectedTenantId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a tenant first.')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('tenant_ratings').add({
        'landlordId': user.uid,
        'tenantId': _selectedTenantId,
        'tenantLabel': _selectedTenantLabel ?? _selectedTenantId,
        'rating': _rating,
        'notes': _notesController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'createdAtLocal': DateTime.now().toIso8601String(),
        'source': 'landlord-rating-card',
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tenant rated ${_rating.toStringAsFixed(1)} / 5.'),
        ),
      );
    } on FirebaseException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save rating (${e.code}).')),
      );
    }
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 11, color: Colors.black54)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    );
  }
}

class _TenantOption {
  const _TenantOption({required this.id, required this.label});

  final String id;
  final String label;
}

DateTime _parseDateTime(dynamic value) {
  if (value is String) {
    return DateTime.tryParse(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
  }
  return DateTime.fromMillisecondsSinceEpoch(0);
}

String _formatDateLabel(String? value) {
  final parsed = value == null ? null : DateTime.tryParse(value);
  if (parsed == null) {
    return 'Unknown date';
  }

  const monthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  return '${parsed.day.toString().padLeft(2, '0')} ${monthNames[parsed.month - 1]} ${parsed.year}';
}

class _TenantTrackerRow {
  const _TenantTrackerRow({
    required this.tenantName,
    required this.amountText,
    required this.statusText,
  });

  final String tenantName;
  final String amountText;
  final String statusText;
}

double _asDouble(dynamic value) {
  if (value is num) {
    return value.toDouble();
  }
  if (value is String) {
    return double.tryParse(value) ?? 0;
  }
  return 0;
}

bool _isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

String _prettifyStatus(String raw) {
  final cleaned = raw.trim().replaceAll('_', ' ');
  if (cleaned.isEmpty) {
    return 'Submitted';
  }
  return cleaned
      .split(' ')
      .where((segment) => segment.isNotEmpty)
      .map((segment) =>
          '${segment[0].toUpperCase()}${segment.substring(1).toLowerCase()}')
      .join(' ');
}

class _TableHeader extends StatelessWidget {
  const _TableHeader(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }
}

Future<String> _resolveRole(String uid) async {
  try {
    final snapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final role = (snapshot.data()?['role'] as String?)?.toLowerCase();
    if (role == 'landlord' || role == 'owner') {
      return 'landlord';
    }
  } catch (_) {
    // Default below.
  }
  return 'tenant';
}
