import 'package:flutter/material.dart';

import '../common/primary_button.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key, required this.onSubmit});

  final Future<void> Function(String email, String password) onSubmit;

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
          label: 'Login',
          onPressed: () =>
              widget.onSubmit(_emailCtrl.text.trim(), _passwordCtrl.text),
        ),
      ],
    );
  }
}
