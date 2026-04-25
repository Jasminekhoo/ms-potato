import 'package:flutter/material.dart';

import '../../models/property_input.dart';
import '../../services/api_service.dart';
import '../common/primary_button.dart';

class PropertyForm extends StatefulWidget {
  const PropertyForm({
    super.key,
    required this.onSubmit,
  });

  final ValueChanged<PropertyInput> onSubmit;

  @override
  State<PropertyForm> createState() => _PropertyFormState();
}

class _PropertyFormState extends State<PropertyForm> {
  final _formKey = GlobalKey<FormState>();
  final _rentCtrl = TextEditingController();
  final _incomeCtrl = TextEditingController();
  final _api = ApiService();

  Map<String, List<String>> _options = const {};
  bool _loadingOptions = true;
  String? _selectedArea;
  String? _selectedProperty;

  @override
  void initState() {
    super.initState();
    _loadOptions();
  }

  @override
  void dispose() {
    _rentCtrl.dispose();
    _incomeCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadOptions() async {
    final options = await _api.getPropertyOptions();
    if (!mounted) return;
    final area = options.keys.isNotEmpty ? options.keys.first : null;
    final properties = area == null ? const <String>[] : options[area] ?? const <String>[];
    setState(() {
      _options = options;
      _selectedArea = area;
      _selectedProperty = properties.isNotEmpty ? properties.first : null;
      _loadingOptions = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final areas = _options.keys.toList()..sort((a, b) => a.compareTo(b));
    final selectedArea =
        (_selectedArea != null && _options.containsKey(_selectedArea))
            ? _selectedArea
            : (areas.isNotEmpty ? areas.first : null);
    final areaProperties =
        selectedArea == null ? const <String>[] : (_options[selectedArea] ?? const <String>[]);
    final selectedProperty = (_selectedProperty != null &&
            areaProperties.contains(_selectedProperty))
        ? _selectedProperty
        : (areaProperties.isNotEmpty ? areaProperties.first : null);

    return Form(
      key: _formKey,
      child: Column(
        children: [
          if (_loadingOptions)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: LinearProgressIndicator(minHeight: 2),
            ),
          DropdownButtonFormField<String>(
            value: selectedArea,
            items: areas
                .map((area) => DropdownMenuItem(value: area, child: Text(area)))
                .toList(),
            decoration: const InputDecoration(labelText: 'Area'),
            onChanged: (value) {
              if (value == null) return;
              final properties = _options[value] ?? const <String>[];
              setState(() {
                _selectedArea = value;
                _selectedProperty =
                    properties.isNotEmpty ? properties.first : null;
              });
            },
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: selectedProperty,
            items: areaProperties
                .map((property) =>
                    DropdownMenuItem(value: property, child: Text(property)))
                .toList(),
            decoration: const InputDecoration(labelText: 'Property name'),
            onChanged: (value) {
              setState(() {
                _selectedProperty = value;
              });
            },
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _rentCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Asking rent (RM)'),
            validator: (v) => (double.tryParse(v ?? '') == null)
                ? 'Enter valid number'
                : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _incomeCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Monthly income (RM)'),
            validator: (v) => (double.tryParse(v ?? '') == null)
                ? 'Enter valid number'
                : null,
          ),
          const SizedBox(height: 18),
          PrimaryButton(
            label: 'Analyse Rental',
            onPressed: () {
              if (!_formKey.currentState!.validate()) return;

              widget.onSubmit(
                PropertyInput(
                  propertyName: selectedProperty ?? '',
                  location: selectedArea ?? '',
                  askingRent: double.parse(_rentCtrl.text),
                  monthlyIncome: double.parse(_incomeCtrl.text),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
