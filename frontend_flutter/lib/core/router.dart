import 'package:go_router/go_router.dart';

import '../screens/analysis/input_screen.dart';
import '../screens/analysis/result_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/compare/compare_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/static/about_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/signup', builder: (context, state) => const SignupScreen()),
    GoRoute(path: '/input', builder: (context, state) => const InputScreen()),
    GoRoute(path: '/result', builder: (context, state) => const ResultScreen()),
    GoRoute(
        path: '/compare', builder: (context, state) => const CompareScreen()),
    GoRoute(path: '/about', builder: (context, state) => const AboutScreen()),
  ],
);
