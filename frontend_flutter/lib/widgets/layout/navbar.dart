import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TopNavBar extends StatelessWidget {
  const TopNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final isWide = MediaQuery.of(context).size.width >= 900;

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
        if (isWide)
          SizedBox(
            width: 240,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                isDense: true,
                prefixIcon: const Icon(Icons.search, size: 20),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        if (isWide) const SizedBox(width: 10),
        _NotificationButton(),
        const SizedBox(width: 6),
        _NavItem(
            label: 'Profile', path: '/profile', active: location == '/profile'),
        const SizedBox(width: 10),
        _NavItem(label: 'Login', path: '/login', active: location == '/login'),
        const SizedBox(width: 10),
        _NavItem(
            label: 'Sign Up', path: '/signup', active: location == '/signup'),
      ],
    );
  }
}

class _NotificationButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const notifications = [
      'Your rent analysis is ready.',
      'New property match found nearby.',
      'Profile update reminder.',
    ];

    return IconButton(
      tooltip: 'Notifications',
      icon: const Icon(Icons.notifications_none),
      onPressed: () {
        showModalBottomSheet<void>(
          context: context,
          showDragHandle: true,
          builder: (context) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notifications',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 10),
                    ...notifications.map(
                      (item) => ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.circle, size: 10),
                        title: Text(item),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
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
