import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

import '../screens/analysis/input_screen.dart';
import '../screens/analysis/result_screen.dart';
import '../screens/compare/compare_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/home/tenant_home_screen.dart';
import '../screens/home/landlord_home_screen.dart';
import '../screens/static/about_screen.dart';
import '../screens/static/profile_screen.dart';
import '../screens/static/payments_screen.dart';

final _authRefreshNotifier =
    _AuthRefreshNotifier(FirebaseAuth.instance.authStateChanges());

final appRouter = GoRouter(
  initialLocation: '/',
  refreshListenable: _authRefreshNotifier,
  redirect: (context, state) async {
    final user = FirebaseAuth.instance.currentUser;
    final location = state.matchedLocation;
    final isAuthPage = location == '/login' || location == '/signup';
    final isProfilePage = location == '/profile';
    final isTenantHome = location == '/tenant-home';
    final isLandlordHome = location == '/landlord-home';

    if (user == null && (isProfilePage || isTenantHome || isLandlordHome)) {
      return '/';
    }

    if (user != null && isAuthPage) {
      final role = await _resolveRole(user.uid);
      return role == 'landlord' ? '/landlord-home' : '/tenant-home';
    }

    if (user != null && (isTenantHome || isLandlordHome)) {
      final role = await _resolveRole(user.uid);
      if (role == 'landlord' && isTenantHome) {
        return '/landlord-home';
      }
      if (role != 'landlord' && isLandlordHome) {
        return '/tenant-home';
      }
    }

    return null;
  },
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/tenant-home',
      builder: (context, state) => const TenantHomeScreen(),
    ),
    GoRoute(
      path: '/landlord-home',
      builder: (context, state) => const LandlordHomeScreen(),
    ),
    GoRoute(path: '/login', builder: (context, state) => const HomeScreen()),
    GoRoute(path: '/signup', builder: (context, state) => const HomeScreen()),
    GoRoute(path: '/input', builder: (context, state) => const InputScreen()),
    GoRoute(path: '/result', builder: (context, state) => const ResultScreen()),
    GoRoute(
        path: '/compare', builder: (context, state) => const CompareScreen()),
    GoRoute(path: '/about', builder: (context, state) => const AboutScreen()),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/payments',
      builder: (context, state) => const PaymentsScreen(),
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

Future<String> _resolveRole(String uid) async {
  try {
    final snapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final role = (snapshot.data()?['role'] as String?)?.toLowerCase();
    if (role == 'landlord' || role == 'owner') {
      return 'landlord';
    }
  } catch (_) {
    // Default below.
  }
  return 'tenant';
}
