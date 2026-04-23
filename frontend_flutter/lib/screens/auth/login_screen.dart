import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

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
                  try {
                    await FirebaseAuth.instance.signInWithEmailAndPassword(
                      email: email,
                      password: password,
                    );

                    if (!context.mounted) {
                      return;
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Login successful.')),
                    );
                    context.go('/profile');
                  } on FirebaseAuthException catch (e) {
                    if (!context.mounted) {
                      return;
                    }

                    String message = 'Login failed. Please try again.';
                    if (e.code == 'invalid-email') {
                      message = 'Invalid email format.';
                    } else if (e.code == 'user-not-found') {
                      message = 'No account found for this email.';
                    } else if (e.code == 'wrong-password' ||
                        e.code == 'invalid-credential') {
                      message = 'Incorrect email or password.';
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(message)),
                    );
                  } catch (_) {
                    if (!context.mounted) {
                      return;
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Unexpected error during login.'),
                      ),
                    );
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
