import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

import '../screens/analysis/input_screen.dart';
import '../screens/analysis/result_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/compare/compare_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/static/about_screen.dart';
import '../screens/static/profile_screen.dart';

final _authRefreshNotifier =
    _AuthRefreshNotifier(FirebaseAuth.instance.authStateChanges());

final appRouter = GoRouter(
  initialLocation: '/',
  refreshListenable: _authRefreshNotifier,
  redirect: (context, state) {
    final user = FirebaseAuth.instance.currentUser;
    final location = state.matchedLocation;
    final isAuthPage = location == '/login' || location == '/signup';
    final isProfilePage = location == '/profile';

    if (user == null && isProfilePage) {
      return '/login';
    }

    if (user != null && isAuthPage) {
      return '/profile';
    }

    return null;
  },
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/signup', builder: (context, state) => const SignupScreen()),
    GoRoute(path: '/input', builder: (context, state) => const InputScreen()),
    GoRoute(path: '/result', builder: (context, state) => const ResultScreen()),
    GoRoute(
        path: '/compare', builder: (context, state) => const CompareScreen()),
    GoRoute(path: '/about', builder: (context, state) => const AboutScreen()),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
  ],
);

class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(Stream<User?> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<User?> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
