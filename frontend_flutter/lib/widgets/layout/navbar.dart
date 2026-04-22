import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TopNavBar extends StatelessWidget {
  const TopNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;

    return Row(
      children: [
        // Menu icon to open Drawer
        Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            tooltip: 'Open navigation menu',
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        IconButton(
          icon: const Icon(Icons.home_outlined),
          tooltip: 'Exit to first page',
          onPressed: () => context.go('/'),
        ),
        const SizedBox(width: 8),
        const Text(
          'AI Rent Advisor',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const Spacer(),
        _NavItem(label: 'Login', path: '/login', active: location == '/login'),
        const SizedBox(width: 10),
        _NavItem(
            label: 'Sign Up', path: '/signup', active: location == '/signup'),
      ],
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.path,
    required this.active,
  });

  final String label;
  final String path;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => context.go(path),
      child: Text(
        label,
        style: TextStyle(
          color:
              active ? Theme.of(context).colorScheme.primary : Colors.black87,
          fontWeight: active ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
    );
  }
}
