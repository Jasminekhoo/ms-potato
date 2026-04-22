import 'package:flutter/material.dart';

import '../../widgets/forms/login_form.dart';
import '../../widgets/layout/app_scaffold.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Login',
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: LoginForm(
                onSubmit: (email, password) async {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text('Login flow is scaffolded for integration.'),
                    ),
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
