import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TopNavBar extends StatelessWidget {
  const TopNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;

    return Row(
      children: [
        const Text(
          'AI Rent Advisor',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const Spacer(),
        _NavItem(
            label: 'Analyse',
            path: '/input',
            active: location == '/input' || location == '/result'),
        const SizedBox(width: 10),
        _NavItem(
            label: 'Compare', path: '/compare', active: location == '/compare'),
        const SizedBox(width: 10),
        _NavItem(
            label: 'Buy vs Rent',
            path: '/buy-vs-rent',
            active: location == '/buy-vs-rent'),
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
