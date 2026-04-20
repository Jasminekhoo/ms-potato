import 'package:flutter/material.dart';

import '../../widgets/forms/signup_form.dart';
import '../../widgets/layout/app_scaffold.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Create Account',
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SignupForm(
                onSubmit: (name, email, password) async {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text('Signup flow is scaffolded for integration.')),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
