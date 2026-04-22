import 'package:flutter/material.dart';

import '../common/primary_button.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key, required this.onSubmit});

  final Future<void> Function(String email, String password) onSubmit;

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submit() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await widget.onSubmit(_emailCtrl.text.trim(), _passwordCtrl.text);
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        children: [
          TextFormField(
            controller: _emailCtrl,
            decoration: const InputDecoration(labelText: 'Email'),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              final email = (value ?? '').trim();
              if (email.isEmpty) {
                return 'Email is required.';
              }
              final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
              if (!emailPattern.hasMatch(email)) {
                return 'Enter a valid email address.';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _passwordCtrl,
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
            validator: (value) {
              final password = value ?? '';
              if (password.isEmpty) {
                return 'Password is required.';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: _isSubmitting ? 'Logging In...' : 'Login',
            onPressed: _isSubmitting ? null : _submit,
          ),
        ],
      ),
    );
  }
}
