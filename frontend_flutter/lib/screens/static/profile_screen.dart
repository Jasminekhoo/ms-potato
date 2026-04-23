import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

import '../../widgets/layout/app_scaffold.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return AppScaffold(
        title: 'Profile',
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Please login to view your profile.'),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () => context.go('/login'),
                      child: const Text('Go to Login'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    final userDocRef =
        FirebaseFirestore.instance.collection('users').doc(user.uid);

    return AppScaffold(
      title: 'Profile',
      child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: userDocRef.snapshots(),
        builder: (context, snapshot) {
          final data = snapshot.data?.data() ?? <String, dynamic>{};
          final fullName = (data['name'] as String?)?.trim().isNotEmpty == true
              ? (data['name'] as String)
              : 'Guest User';
          final nameParts = fullName.split(' ');
          final firstName = data['firstName'] as String? ?? nameParts.first;
          final lastName = data['lastName'] as String? ??
              (nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '-');
          final email = (data['email'] as String?)?.trim().isNotEmpty == true
              ? data['email'] as String
              : (user.email ?? '-');
          final role = _formatRole(data['role'] as String?);
          final memberSince = _formatTimestamp(data['memberSince']);
          final phoneNumber = (data['phoneNumber'] as String?) ?? '-';
          final state = (data['state'] as String?) ?? '-';
          final country = (data['country'] as String?) ?? '-';
          final dateOfBirth = (data['dateOfBirth'] as String?) ?? '-';
          final lookingFor = (data['lookingFor'] as String?) ?? '-';
          final desiredMoveInDate =
              (data['desiredMoveInDate'] as String?) ?? '-';
          final leaseDuration = (data['leaseDuration'] as String?) ?? '-';
          final pets = (data['pets'] as String?) ?? '-';
          final parkingSpace = (data['parkingSpace'] as String?) ?? '-';
          final preferredAmenities =
              (data['preferredAmenities'] as String?) ?? '-';

          final rentalHistoryRaw =
              (data['rentalHistory'] as List<dynamic>?) ?? const [];

          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: ListView(
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const CircleAvatar(
                              radius: 26,
                              child: Icon(Icons.person_outline),
                            ),
                            title: Text(fullName),
                            subtitle: Text('Role: $role'),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                await showDialog<void>(
                                  context: context,
                                  builder: (_) => _EditProfileDialog(
                                    userDocRef: userDocRef,
                                    data: data,
                                  ),
                                );
                              },
                              icon: const Icon(Icons.edit_outlined),
                              label: const Text('Edit'),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Divider(),
                          const SizedBox(height: 12),
                          const _SectionTitle('Personal Information'),
                          const SizedBox(height: 10),
                          _ProfileRow(label: 'First Name', value: firstName),
                          const SizedBox(height: 8),
                          _ProfileRow(label: 'Last Name', value: lastName),
                          const SizedBox(height: 8),
                          _ProfileRow(
                              label: 'Date of Birth', value: dateOfBirth),
                          const SizedBox(height: 8),
                          _ProfileRow(
                              label: 'Member Since', value: memberSince),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _SectionTitle('Contact and Location'),
                          const SizedBox(height: 10),
                          _ProfileRow(
                              label: 'Phone Number', value: phoneNumber),
                          const SizedBox(height: 8),
                          _ProfileRow(label: 'Email Address', value: email),
                          const SizedBox(height: 8),
                          _ProfileRow(label: 'State', value: state),
                          const SizedBox(height: 8),
                          _ProfileRow(label: 'Country', value: country),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _SectionTitle('Preferences'),
                          const SizedBox(height: 10),
                          _ProfileRow(label: 'Looking For', value: lookingFor),
                          const SizedBox(height: 8),
                          _ProfileRow(
                            label: 'Move-In Date',
                            value: desiredMoveInDate,
                          ),
                          const SizedBox(height: 8),
                          _ProfileRow(
                            label: 'Lease Duration',
                            value: leaseDuration,
                          ),
                          const SizedBox(height: 8),
                          _ProfileRow(label: 'Pets', value: pets),
                          const SizedBox(height: 8),
                          _ProfileRow(
                            label: 'Parking Space',
                            value: parkingSpace,
                          ),
                          const SizedBox(height: 8),
                          _ProfileRow(
                            label: 'Amenities',
                            value: preferredAmenities,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _SectionTitle('Rental History'),
                          const SizedBox(height: 10),
                          if (rentalHistoryRaw.isEmpty)
                            const Text('No rental history added yet.')
                          else
                            ..._buildRentalHistory(rentalHistoryRaw),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  static String _formatTimestamp(dynamic rawValue) {
    if (rawValue is Timestamp) {
      final date = rawValue.toDate();
      final month = _monthName(date.month);
      return '$month ${date.year}';
    }
    return '-';
  }

  static String _monthName(int month) {
    const months = [
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
    return months[month - 1];
  }

  static String _formatRole(String? role) {
    final value = role?.trim().toLowerCase();
    if (value == 'landlord' || value == 'owner') {
      return 'Landlord';
    }
    if (value == 'tenant') {
      return 'Tenant';
    }
    return 'Not selected';
  }

  static List<Widget> _buildRentalHistory(List<dynamic> items) {
    final widgets = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      final entry = (items[i] as Map<String, dynamic>?) ?? const {};
      widgets.add(
        _RentalHistoryItem(
          place: (entry['place'] as String?) ?? '-',
          duration: (entry['duration'] as String?) ?? '-',
          landlordRating: (entry['landlordRating'] as String?) ?? '-',
        ),
      );
      if (i < items.length - 1) {
        widgets.add(const Divider(height: 24));
      }
    }
    return widgets;
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(child: Text(value)),
      ],
    );
  }
}

class _RentalHistoryItem extends StatelessWidget {
  const _RentalHistoryItem({
    required this.place,
    required this.duration,
    required this.landlordRating,
  });

  final String place;
  final String duration;
  final String landlordRating;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          place,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        _ProfileRow(label: 'Duration', value: duration),
        const SizedBox(height: 6),
        _ProfileRow(label: 'Landlord Rating', value: landlordRating),
      ],
    );
  }
}

class _EditProfileDialog extends StatefulWidget {
  const _EditProfileDialog({required this.userDocRef, required this.data});

  final DocumentReference<Map<String, dynamic>> userDocRef;
  final Map<String, dynamic> data;

  @override
  State<_EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<_EditProfileDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _firstNameCtrl;
  late final TextEditingController _lastNameCtrl;
  late final TextEditingController _dobCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _stateCtrl;
  late final TextEditingController _countryCtrl;
  late final TextEditingController _lookingForCtrl;
  late final TextEditingController _moveInDateCtrl;
  late final TextEditingController _leaseDurationCtrl;
  late final TextEditingController _petsCtrl;
  late final TextEditingController _parkingSpaceCtrl;
  late final TextEditingController _amenitiesCtrl;
  late final TextEditingController _rentalHistoryCtrl;

  String _selectedRole = 'tenant';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final data = widget.data;

    final fullName = (data['name'] as String?)?.trim().isNotEmpty == true
        ? (data['name'] as String)
        : '';
    final nameParts = fullName.split(' ');

    final firstName = _cleanValue(
      data['firstName'] as String? ??
          (nameParts.isNotEmpty ? nameParts.first : ''),
    );
    final lastName = _cleanValue(
      data['lastName'] as String? ??
          (nameParts.length > 1 ? nameParts.sublist(1).join(' ') : ''),
    );

    _firstNameCtrl = TextEditingController(text: firstName);
    _lastNameCtrl = TextEditingController(text: lastName);
    _dobCtrl = TextEditingController(
        text: _cleanValue(data['dateOfBirth'] as String?));
    _phoneCtrl = TextEditingController(
        text: _cleanValue(data['phoneNumber'] as String?));
    _stateCtrl =
        TextEditingController(text: _cleanValue(data['state'] as String?));
    _countryCtrl =
        TextEditingController(text: _cleanValue(data['country'] as String?));
    _lookingForCtrl =
        TextEditingController(text: _cleanValue(data['lookingFor'] as String?));
    _moveInDateCtrl = TextEditingController(
      text: _cleanValue(data['desiredMoveInDate'] as String?),
    );
    _leaseDurationCtrl = TextEditingController(
      text: _cleanValue(data['leaseDuration'] as String?),
    );
    _petsCtrl =
        TextEditingController(text: _cleanValue(data['pets'] as String?));
    _parkingSpaceCtrl = TextEditingController(
      text: _cleanValue(data['parkingSpace'] as String?),
    );
    _amenitiesCtrl = TextEditingController(
      text: _cleanValue(data['preferredAmenities'] as String?),
    );

    final roleFromDb = (data['role'] as String?)?.trim().toLowerCase();
    _selectedRole = (roleFromDb == 'landlord' || roleFromDb == 'owner')
        ? 'landlord'
        : 'tenant';

    _rentalHistoryCtrl = TextEditingController(
      text: _serializeRentalHistory(
          (data['rentalHistory'] as List<dynamic>?) ?? const []),
    );
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _dobCtrl.dispose();
    _phoneCtrl.dispose();
    _stateCtrl.dispose();
    _countryCtrl.dispose();
    _lookingForCtrl.dispose();
    _moveInDateCtrl.dispose();
    _leaseDurationCtrl.dispose();
    _petsCtrl.dispose();
    _parkingSpaceCtrl.dispose();
    _amenitiesCtrl.dispose();
    _rentalHistoryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Profile'),
      content: SizedBox(
        width: 520,
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Personal Information',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _firstNameCtrl,
                  decoration: const InputDecoration(labelText: 'First Name'),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Required'
                      : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _lastNameCtrl,
                  decoration: const InputDecoration(labelText: 'Last Name'),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _dobCtrl,
                  readOnly: true,
                  onTap: _isSaving
                      ? null
                      : () => _pickDateForController(
                            _dobCtrl,
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          ),
                  decoration: const InputDecoration(
                    labelText: 'Date of Birth',
                    suffixIcon: Icon(Icons.calendar_month_outlined),
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  decoration: const InputDecoration(labelText: 'Role'),
                  items: const [
                    DropdownMenuItem(value: 'tenant', child: Text('Tenant')),
                    DropdownMenuItem(
                        value: 'landlord', child: Text('Landlord')),
                  ],
                  onChanged: _isSaving
                      ? null
                      : (value) {
                          if (value != null) {
                            setState(() {
                              _selectedRole = value;
                            });
                          }
                        },
                ),
                const SizedBox(height: 14),
                const Text('Contact and Location',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _phoneCtrl,
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _stateCtrl,
                  decoration: const InputDecoration(labelText: 'State'),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _countryCtrl,
                  decoration: const InputDecoration(labelText: 'Country'),
                ),
                const SizedBox(height: 14),
                const Text('Preferences',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _lookingForCtrl,
                  decoration: const InputDecoration(labelText: 'Looking For'),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _moveInDateCtrl,
                  readOnly: true,
                  onTap: _isSaving
                      ? null
                      : () => _pickDateForController(
                            _moveInDateCtrl,
                            firstDate: DateTime(2000),
                            lastDate:
                                DateTime.now().add(const Duration(days: 3650)),
                          ),
                  decoration: const InputDecoration(
                    labelText: 'Desired Move-In Date',
                    suffixIcon: Icon(Icons.calendar_month_outlined),
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _leaseDurationCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Lease Duration'),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _petsCtrl,
                  decoration: const InputDecoration(labelText: 'Pets'),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _parkingSpaceCtrl,
                  decoration: const InputDecoration(labelText: 'Parking Space'),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _amenitiesCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Preferred Amenities'),
                ),
                const SizedBox(height: 14),
                const Text('Rental History',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                const Text(
                  'One line per rental: Place | Duration | Landlord Rating',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _rentalHistoryCtrl,
                  minLines: 3,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    hintText: 'Sunway Condo | Mar 2024 - Present | 4.7 / 5',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _save,
          child: Text(_isSaving ? 'Saving...' : 'Save'),
        ),
      ],
    );
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final firstName = _firstNameCtrl.text.trim();
    final lastName = _lastNameCtrl.text.trim();
    final fullName = [firstName, lastName].where((s) => s.isNotEmpty).join(' ');

    final update = <String, dynamic>{
      'firstName': firstName,
      'lastName': lastName,
      'name': fullName,
      'dateOfBirth': _dobCtrl.text.trim(),
      'role': _selectedRole,
      'phoneNumber': _phoneCtrl.text.trim(),
      'state': _stateCtrl.text.trim(),
      'country': _countryCtrl.text.trim(),
      'lookingFor': _lookingForCtrl.text.trim(),
      'desiredMoveInDate': _moveInDateCtrl.text.trim(),
      'leaseDuration': _leaseDurationCtrl.text.trim(),
      'pets': _petsCtrl.text.trim(),
      'parkingSpace': _parkingSpaceCtrl.text.trim(),
      'preferredAmenities': _amenitiesCtrl.text.trim(),
      'rentalHistory': _parseRentalHistory(_rentalHistoryCtrl.text),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    try {
      await widget.userDocRef.set(update, SetOptions(merge: true));
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully.')),
      );
    } on FirebaseException catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save profile (${e.code}).')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  static String _cleanValue(String? value) {
    final clean = (value ?? '').trim();
    return clean == '-' ? '' : clean;
  }

  static String _serializeRentalHistory(List<dynamic> items) {
    final lines = <String>[];
    for (final item in items) {
      final entry = (item as Map<String, dynamic>?) ?? const {};
      final place = (entry['place'] as String?)?.trim() ?? '';
      final duration = (entry['duration'] as String?)?.trim() ?? '';
      final rating = (entry['landlordRating'] as String?)?.trim() ?? '';
      if (place.isEmpty && duration.isEmpty && rating.isEmpty) {
        continue;
      }
      lines.add('$place | $duration | $rating');
    }
    return lines.join('\n');
  }

  static List<Map<String, String>> _parseRentalHistory(String raw) {
    final lines = raw
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    final history = <Map<String, String>>[];
    for (final line in lines) {
      final parts = line.split('|').map((e) => e.trim()).toList();
      history.add({
        'place': parts.isNotEmpty ? parts[0] : '',
        'duration': parts.length > 1 ? parts[1] : '',
        'landlordRating': parts.length > 2 ? parts[2] : '',
      });
    }
    return history;
  }

  Future<void> _pickDateForController(
    TextEditingController controller, {
    required DateTime firstDate,
    required DateTime lastDate,
  }) async {
    final parsedDate = _tryParseDate(controller.text);
    var initialDate = parsedDate ?? DateTime.now();
    if (initialDate.isBefore(firstDate)) {
      initialDate = firstDate;
    }
    if (initialDate.isAfter(lastDate)) {
      initialDate = lastDate;
    }

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (pickedDate == null || !mounted) {
      return;
    }

    setState(() {
      controller.text = _formatDate(pickedDate);
    });
  }

  static String _formatDate(DateTime date) {
    final yyyy = date.year.toString().padLeft(4, '0');
    final mm = date.month.toString().padLeft(2, '0');
    final dd = date.day.toString().padLeft(2, '0');
    return '$yyyy-$mm-$dd';
  }

  static DateTime? _tryParseDate(String raw) {
    final text = raw.trim();
    if (text.isEmpty) {
      return null;
    }

    final isoParsed = DateTime.tryParse(text);
    if (isoParsed != null) {
      return DateTime(isoParsed.year, isoParsed.month, isoParsed.day);
    }

    final shortMonthPattern = RegExp(r'^(\d{1,2})\s([A-Za-z]{3})\s(\d{4})$');
    final match = shortMonthPattern.firstMatch(text);
    if (match == null) {
      return null;
    }

    const monthIndex = {
      'jan': 1,
      'feb': 2,
      'mar': 3,
      'apr': 4,
      'may': 5,
      'jun': 6,
      'jul': 7,
      'aug': 8,
      'sep': 9,
      'oct': 10,
      'nov': 11,
      'dec': 12,
    };

    final day = int.tryParse(match.group(1)!);
    final month = monthIndex[match.group(2)!.toLowerCase()];
    final year = int.tryParse(match.group(3)!);
    if (day == null || month == null || year == null) {
      return null;
    }

    return DateTime(year, month, day);
  }
}
