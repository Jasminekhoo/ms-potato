import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

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
                onSubmit: (name, email, password, role) async {
                  try {
                    final credential = await FirebaseAuth.instance
                        .createUserWithEmailAndPassword(
                      email: email,
                      password: password,
                    );

                    String? profileWriteWarning;
                    try {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(credential.user!.uid)
                          .set({
                        'name': name,
                        'email': email,
                        'role': role.name,
                        'memberSince': FieldValue.serverTimestamp(),
                      });
                    } on FirebaseException catch (e) {
                      profileWriteWarning =
                          'Account created, but profile save failed (${e.code}).';
                    }

                    if (!context.mounted) {
                      return;
                    }

                    final message = profileWriteWarning ??
                        'Account created as ${role == UserRole.tenant ? 'Tenant' : 'Owner'}.';
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(message)));
                    context.go('/profile');
                  } on FirebaseAuthException catch (e) {
                    if (!context.mounted) {
                      return;
                    }

                    String message = 'Sign up failed. Please try again.';
                    if (e.code == 'invalid-email') {
                      message = 'Invalid email format.';
                    } else if (e.code == 'email-already-in-use') {
                      message = 'This email is already registered.';
                    } else if (e.code == 'weak-password') {
                      message = 'Password is too weak (min 6 characters).';
                    } else if (e.code == 'operation-not-allowed') {
                      message =
                          'Email/password sign-in is disabled in Firebase Auth.';
                    } else if (e.code == 'network-request-failed') {
                      message = 'Network error. Check internet and try again.';
                    } else if (e.code == 'too-many-requests') {
                      message = 'Too many attempts. Please wait and try again.';
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
                        content: Text('Unexpected error during sign up.'),
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
