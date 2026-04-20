import 'package:flutter/material.dart';

import '../common/primary_button.dart';

class SignupForm extends StatefulWidget {
  const SignupForm({super.key, required this.onSubmit});

  final Future<void> Function(String name, String email, String password)
      onSubmit;

  @override
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(labelText: 'Name')),
        const SizedBox(height: 12),
        TextField(
            controller: _emailCtrl,
            decoration: const InputDecoration(labelText: 'Email')),
        const SizedBox(height: 12),
        TextField(
          controller: _passwordCtrl,
          decoration: const InputDecoration(labelText: 'Password'),
          obscureText: true,
        ),
        const SizedBox(height: 16),
        PrimaryButton(
          label: 'Create Account',
          onPressed: () => widget.onSubmit(
            _nameCtrl.text.trim(),
            _emailCtrl.text.trim(),
            _passwordCtrl.text,
          ),
        ),
      ],
    );
  }
}
