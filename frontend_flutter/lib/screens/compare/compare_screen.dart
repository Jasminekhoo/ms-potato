import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/utils.dart';
import '../../models/compare_result.dart';
import '../../models/property_input.dart';
import '../../services/api_service.dart';
import '../../widgets/common/loading_skeleton.dart';
import '../../widgets/common/primary_button.dart';
import '../../widgets/layout/app_scaffold.dart';

class CompareScreen extends StatefulWidget {
  const CompareScreen({super.key});

  @override
  State<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends State<CompareScreen> {
  static const int _maxDrafts = 5;
  static const String _draftStorageKey = 'compare_drafts_v1';
  static const String _draftSavedAtKey = 'compare_drafts_saved_at_v1';
  static const List<String> _allowedListingDomains = [
    'propertyguru.com.my',
    'iproperty.com.my',
    'mudah.my',
  ];
  late final List<_CompareDraft> _drafts;
  bool _isLoading = false;
  List<CompareProperty> _items = const [];
  String? _error;
  DateTime? _lastSavedAt;
  final Map<_CompareDraft, String> _draftErrors = {};

  List<_CompareDraft> _defaultDrafts() {
    return [
      _CompareDraft('Vista Harmoni Residences', 'Cheras', '1,850', '6,500'),
      _CompareDraft('Midcity Heights', 'Taman Midah', '2,100', '6,500'),
      _CompareDraft('Lakepoint Suites', 'Sri Petaling', '2,300', '6,500'),
    ];
  }

  @override
  void initState() {
    super.initState();
    _drafts = _defaultDrafts();
    _loadDrafts();
  }

  @override
  void dispose() {
    for (final draft in _drafts) {
      draft.dispose();
    }
    super.dispose();
  }

  Future<void> _runCompare() async {
    final isValid = _validateDrafts();
    if (!isValid) {
      setState(() {
        _error = 'Fix the highlighted compare cards before running compare.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final properties = _drafts
          .map((d) => PropertyInput(
                propertyName: d.propertyName.text.trim(),
                location: d.location.text.trim(),
                askingRent: _parseAmount(d.askingRent.text),
                monthlyIncome: _parseAmount(d.monthlyIncome.text),
              ))
          .toList();

      final response = await ApiService().compare(properties);
      if (!mounted) return;

      setState(() {
        _items = response;
      });
      await _saveDrafts();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Unable to compare properties right now.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  bool _looksLikeSupportedDomain(String host) {
    final normalized = host.toLowerCase();
    for (final domain in _allowedListingDomains) {
      if (normalized == domain || normalized.endsWith('.$domain')) {
        return true;
      }
    }
    return false;
  }

  String _hostBase(String host) {
    final lower = host.toLowerCase();
    if (lower.endsWith('propertyguru.com.my')) return 'propertyguru.com.my';
    if (lower.endsWith('iproperty.com.my')) return 'iproperty.com.my';
    if (lower.endsWith('mudah.my')) return 'mudah.my';
    return lower;
  }

  bool _validateDrafts() {
    final errors = <_CompareDraft, String>{};

    for (final draft in _drafts) {
      final name = draft.propertyName.text.trim();
      final location = draft.location.text.trim();
      final rent = _parseAmount(draft.askingRent.text);
      final income = _parseAmount(draft.monthlyIncome.text);

      if (name.isEmpty) {
        errors[draft] = 'Property name is required.';
        continue;
      }
      if (location.isEmpty) {
        errors[draft] = 'Location is required.';
        continue;
      }
      if (rent <= 0) {
        errors[draft] = 'Asking rent must be a positive number.';
        continue;
      }
      if (income <= 0) {
        errors[draft] = 'Monthly income must be a positive number.';
        continue;
      }

      final listingUrl = draft.listingUrl.text.trim();
      if (listingUrl.isNotEmpty) {
        final uri = Uri.tryParse(listingUrl);
        if (uri == null || uri.host.isEmpty) {
          errors[draft] = 'Listing URL is invalid.';
          continue;
        }
        if (uri.scheme != 'http' && uri.scheme != 'https') {
          errors[draft] = 'Listing URL must start with http or https.';
          continue;
        }
        if (!_looksLikeSupportedDomain(uri.host)) {
          errors[draft] =
              'Use a supported listing domain: PropertyGuru, iProperty, or Mudah.';
          continue;
        }
      }
    }

    setState(() {
      _draftErrors
        ..clear()
        ..addAll(errors);
    });
    return errors.isEmpty;
  }

  double _parseAmount(String raw) {
    final normalized = raw.replaceAll(',', '').trim();
    return double.tryParse(normalized) ?? 0;
  }

  String _lastSavedLabel() {
    final value = _lastSavedAt;
    if (value == null) return 'Not saved yet';

    final hh = value.hour.toString().padLeft(2, '0');
    final mm = value.minute.toString().padLeft(2, '0');
    return 'Last saved: $hh:$mm';
  }

  void _addDraft() {
    if (_drafts.length >= _maxDrafts) return;
    setState(() {
      _drafts.add(_CompareDraft('', '', '0', '0'));
    });
    _saveDrafts();
  }

  void _removeDraft(int index) {
    if (_drafts.length <= 1) return;

    setState(() {
      final draft = _drafts.removeAt(index);
      draft.dispose();
    });
    _saveDrafts();
  }

  void _reorderDrafts(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = _drafts.removeAt(oldIndex);
      _drafts.insert(newIndex, item);
    });
    _saveDrafts();
  }

  String _titleCaseWords(String value) {
    final words =
        value.split(RegExp(r'\s+')).where((w) => w.trim().isNotEmpty).toList();

    return words
        .map((w) => '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
        .join(' ');
  }

  String _extractPropertyNameFromUri(Uri uri) {
    final base = _hostBase(uri.host);
    if (base == 'iproperty.com.my') {
      final title = uri.queryParameters['title'];
      if (title != null && title.trim().isNotEmpty) return title;
    }
    if (base == 'mudah.my') {
      final queryTitle = uri.queryParameters['q'];
      if (queryTitle != null && queryTitle.trim().isNotEmpty) {
        return queryTitle;
      }
    }

    final segments =
        uri.pathSegments.where((s) => s.trim().isNotEmpty).toList();
    final preferred = segments.isNotEmpty ? segments.last : uri.host;
    return preferred
        .replaceAll(RegExp(r'[-_]+'), ' ')
        .replaceAll(RegExp(r'\d+'), '')
        .trim();
  }

  String _extractLocationHint(String source) {
    final lower = source.toLowerCase();
    if (lower.contains('cheras')) return 'Cheras';
    if (lower.contains('sri-petaling') || lower.contains('sri petaling')) {
      return 'Sri Petaling';
    }
    if (lower.contains('taman-midah') || lower.contains('taman midah')) {
      return 'Taman Midah';
    }
    if (lower.contains('ara-damansara') || lower.contains('ara damansara')) {
      return 'Ara Damansara';
    }
    if (lower.contains('damansara')) return 'Damansara';
    if (lower.contains('ampang')) return 'Ampang';
    return '';
  }

  void _applyListingUrl(_CompareDraft draft, String rawUrl) {
    final uri = Uri.tryParse(rawUrl.trim());
    if (uri == null || uri.host.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid listing URL.')),
      );
      return;
    }
    if (uri.scheme != 'http' && uri.scheme != 'https') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('URL must start with http:// or https://.')),
      );
      return;
    }
    if (!_looksLikeSupportedDomain(uri.host)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unsupported domain. Use PropertyGuru, iProperty, or Mudah listing links.',
          ),
        ),
      );
      return;
    }

    final baseHost = _hostBase(uri.host);

    final cleaned = _extractPropertyNameFromUri(uri);

    if (cleaned.isNotEmpty && draft.propertyName.text.trim().isEmpty) {
      draft.propertyName.text = _titleCaseWords(cleaned);
    }

    if (draft.location.text.trim().isEmpty) {
      final fromPath = _extractLocationHint(rawUrl);
      if (fromPath.isNotEmpty) {
        draft.location.text = fromPath;
      }
    }

    draft.listingUrl.text = rawUrl.trim();
    _draftErrors.remove(draft);
    _saveDrafts();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Listing parsed from ${baseHost == uri.host ? uri.host : baseHost}.',
        ),
      ),
    );
  }

  Future<void> _pasteUrlAndApply(_CompareDraft draft) async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim() ?? '';
    if (text.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Clipboard is empty.')),
      );
      return;
    }

    if (!mounted) return;
    _applyListingUrl(draft, text);
    setState(() {});
  }

  Future<void> _resetDrafts() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reset Compare Cards?'),
          content: const Text(
            'This will clear current compare inputs and restore the 3 demo cards.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      for (final draft in _drafts) {
        draft.dispose();
      }
      _drafts
        ..clear()
        ..addAll(_defaultDrafts());
      _draftErrors.clear();
      _error = null;
    });

    await _saveDrafts();
    await _runCompare();
  }

  Future<void> _saveDrafts() async {
    final prefs = await SharedPreferences.getInstance();
    final payload = _drafts.map((d) => d.toJson()).toList(growable: false);
    await prefs.setString(_draftStorageKey, jsonEncode(payload));
    final now = DateTime.now();
    await prefs.setString(_draftSavedAtKey, now.toIso8601String());
    if (mounted) {
      setState(() {
        _lastSavedAt = now;
      });
    }
  }

  Future<void> _loadDrafts() async {
    final prefs = await SharedPreferences.getInstance();
    final savedAtRaw = prefs.getString(_draftSavedAtKey);
    if (savedAtRaw != null) {
      _lastSavedAt = DateTime.tryParse(savedAtRaw);
    }
    final raw = prefs.getString(_draftStorageKey);
    if (raw == null || raw.trim().isEmpty) {
      await _runCompare();
      return;
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        await _runCompare();
        return;
      }

      for (final draft in _drafts) {
        draft.dispose();
      }
      _drafts.clear();

      for (final item in decoded) {
        if (item is Map<String, dynamic>) {
          _drafts.add(_CompareDraft.fromJson(item));
        } else if (item is Map) {
          _drafts.add(_CompareDraft.fromJson(item.cast<String, dynamic>()));
        }
      }

      if (_drafts.isEmpty) {
        _drafts.add(_CompareDraft('', '', '0', '0'));
      }

      if (mounted) {
        setState(() {});
      }
      await _runCompare();
    } catch (_) {
      await _runCompare();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Comparisons',
      child: ListView(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Compare up to 5 properties',
                      style:
                          TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Currently comparing ${_drafts.length} property ${_drafts.length == 1 ? 'card' : 'cards'}',
                              style: const TextStyle(color: Colors.black54),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _lastSavedLabel(),
                              style: const TextStyle(
                                color: Colors.black45,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _resetDrafts,
                        icon: const Icon(Icons.restart_alt),
                        label: const Text('Reset All'),
                      ),
                      TextButton.icon(
                        onPressed:
                            _drafts.length < _maxDrafts ? _addDraft : null,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Card'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ReorderableListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _drafts.length,
                    onReorder: _reorderDrafts,
                    buildDefaultDragHandles: false,
                    itemBuilder: (context, index) {
                      return Padding(
                        key: ValueKey(_drafts[index]),
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _CompareInputCard(
                          index: index + 1,
                          draft: _drafts[index],
                          errorText: _draftErrors[_drafts[index]],
                          domainHint:
                              'Supported: propertyguru.com.my, iproperty.com.my, mudah.my',
                          onRemove: _drafts.length > 1
                              ? () => _removeDraft(index)
                              : null,
                          onPasteUrl: () => _pasteUrlAndApply(_drafts[index]),
                          onParseUrl: () => _applyListingUrl(
                            _drafts[index],
                            _drafts[index].listingUrl.text,
                          ),
                          onChanged: _saveDrafts,
                          dragHandle: ReorderableDragStartListener(
                            index: index,
                            child: const Icon(Icons.drag_indicator),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                  PrimaryButton(label: 'Run Compare', onPressed: _runCompare),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (_isLoading)
            const LoadingSkeleton()
          else ...[
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Color(0xFFB91C1C)),
                ),
              ),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _items.map((e) => _CompareCard(item: e)).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _CompareDraft {
  _CompareDraft(String name, String locationValue, String rent, String income)
      : propertyName = TextEditingController(text: name),
        listingUrl = TextEditingController(),
        location = TextEditingController(text: locationValue),
        askingRent = TextEditingController(text: rent),
        monthlyIncome = TextEditingController(text: income);

  _CompareDraft.fromJson(Map<String, dynamic> json)
      : propertyName = TextEditingController(
          text: (json['propertyName'] ?? '').toString(),
        ),
        listingUrl = TextEditingController(
          text: (json['listingUrl'] ?? '').toString(),
        ),
        location = TextEditingController(
          text: (json['location'] ?? '').toString(),
        ),
        askingRent = TextEditingController(
          text: (json['askingRent'] ?? '0').toString(),
        ),
        monthlyIncome = TextEditingController(
          text: (json['monthlyIncome'] ?? '0').toString(),
        );

  final TextEditingController propertyName;
  final TextEditingController listingUrl;
  final TextEditingController location;
  final TextEditingController askingRent;
  final TextEditingController monthlyIncome;

  Map<String, dynamic> toJson() {
    return {
      'propertyName': propertyName.text.trim(),
      'listingUrl': listingUrl.text.trim(),
      'location': location.text.trim(),
      'askingRent': askingRent.text.trim(),
      'monthlyIncome': monthlyIncome.text.trim(),
    };
  }

  void dispose() {
    propertyName.dispose();
    listingUrl.dispose();
    location.dispose();
    askingRent.dispose();
    monthlyIncome.dispose();
  }
}

class _CompareInputCard extends StatelessWidget {
  const _CompareInputCard({
    required this.index,
    required this.draft,
    required this.domainHint,
    required this.onPasteUrl,
    required this.onParseUrl,
    required this.onChanged,
    required this.dragHandle,
    this.errorText,
    this.onRemove,
  });

  final int index;
  final _CompareDraft draft;
  final String domainHint;
  final VoidCallback onPasteUrl;
  final VoidCallback onParseUrl;
  final VoidCallback onChanged;
  final Widget dragHandle;
  final String? errorText;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                dragHandle,
                const SizedBox(width: 6),
                Text('Property $index',
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                const Spacer(),
                TextButton.icon(
                  onPressed: onPasteUrl,
                  icon: const Icon(Icons.paste, size: 18),
                  label: const Text('Paste URL'),
                ),
              ],
            ),
            if (onRemove != null)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: onRemove,
                  icon: const Icon(Icons.remove_circle_outline),
                  label: const Text('Remove'),
                ),
              ),
            const SizedBox(height: 8),
            TextField(
              controller: draft.listingUrl,
              onChanged: (_) => onChanged(),
              decoration: InputDecoration(
                labelText: 'Listing URL',
                helperText: domainHint,
                suffixIcon: IconButton(
                  onPressed: onParseUrl,
                  icon: const Icon(Icons.auto_fix_high),
                  tooltip: 'Parse URL',
                ),
              ),
            ),
            if (errorText != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  errorText!,
                  style: const TextStyle(
                    color: Color(0xFFB91C1C),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            const SizedBox(height: 8),
            TextField(
              controller: draft.propertyName,
              onChanged: (_) => onChanged(),
              decoration: const InputDecoration(labelText: 'Property name'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: draft.location,
              onChanged: (_) => onChanged(),
              decoration: const InputDecoration(labelText: 'Location'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: draft.askingRent,
              keyboardType: TextInputType.number,
              inputFormatters: [_ThousandsSeparatorFormatter()],
              onChanged: (_) => onChanged(),
              decoration: const InputDecoration(labelText: 'Asking rent (RM)'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: draft.monthlyIncome,
              keyboardType: TextInputType.number,
              inputFormatters: [_ThousandsSeparatorFormatter()],
              onChanged: (_) => onChanged(),
              decoration:
                  const InputDecoration(labelText: 'Monthly income (RM)'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompareCard extends StatelessWidget {
  const _CompareCard({required this.item});

  final CompareProperty item;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 330,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 18)),
              const SizedBox(height: 4),
              Text(item.location,
                  style: const TextStyle(color: Colors.black54)),
              const SizedBox(height: 14),
              Text('Verdict: ${item.verdict}',
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Text('True Cost: ${Currency.rm(item.trueCostMonthly)}/mo'),
              const SizedBox(height: 6),
              Text('Risk: ${item.riskScore.toStringAsFixed(1)}/10'),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThousandsSeparatorFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) {
      return const TextEditingValue(text: '');
    }

    final chars = digits.split('').reversed.toList();
    final buffer = StringBuffer();
    for (var i = 0; i < chars.length; i++) {
      if (i > 0 && i % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(chars[i]);
    }
    final formatted = buffer.toString().split('').reversed.join();

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
