import 'package:flutter/material.dart';

import '../../models/property_input.dart';
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
  final _propertyCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _rentCtrl = TextEditingController();
  final _incomeCtrl = TextEditingController();

  @override
  void dispose() {
    _propertyCtrl.dispose();
    _locationCtrl.dispose();
    _rentCtrl.dispose();
    _incomeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _propertyCtrl,
            decoration: const InputDecoration(labelText: 'Property name'),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Required' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _locationCtrl,
            decoration: const InputDecoration(labelText: 'Location / postcode'),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Required' : null,
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
                  propertyName: _propertyCtrl.text.trim(),
                  location: _locationCtrl.text.trim(),
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
