import 'package:flutter/material.dart';

import '../common/primary_button.dart';

enum UserRole { tenant, owner }

class SignupForm extends StatefulWidget {
  const SignupForm({super.key, required this.onSubmit});

  final Future<void> Function(
    String name,
    String email,
    String password,
    UserRole role,
  ) onSubmit;

  @override
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  UserRole _selectedRole = UserRole.tenant;
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
      await widget.onSubmit(
        _nameCtrl.text.trim(),
        _emailCtrl.text.trim(),
        _passwordCtrl.text,
        _selectedRole,
      );
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
    _nameCtrl.dispose();
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _nameCtrl,
            decoration: const InputDecoration(labelText: 'Name'),
            validator: (value) {
              final name = (value ?? '').trim();
              if (name.isEmpty) {
                return 'Name is required.';
              }
              if (name.length < 2) {
                return 'Name must be at least 2 characters.';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
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
              if (password.length < 6) {
                return 'Password must be at least 6 characters.';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Text('Sign up as:', style: Theme.of(context).textTheme.bodyMedium),
          Row(
            children: [
              Radio<UserRole>(
                value: UserRole.tenant,
                groupValue: _selectedRole,
                onChanged: _isSubmitting
                    ? null
                    : (value) {
                        setState(() {
                          _selectedRole = value!;
                        });
                      },
              ),
              const Text('Tenant'),
              Radio<UserRole>(
                value: UserRole.owner,
                groupValue: _selectedRole,
                onChanged: _isSubmitting
                    ? null
                    : (value) {
                        setState(() {
                          _selectedRole = value!;
                        });
                      },
              ),
              const Text('Owner'),
            ],
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: _isSubmitting ? 'Creating Account...' : 'Create Account',
            onPressed: _isSubmitting ? null : _submit,
          ),
        ],
      ),
    );
  }
}
