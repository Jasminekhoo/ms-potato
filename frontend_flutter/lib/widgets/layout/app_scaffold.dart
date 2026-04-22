import 'package:flutter/material.dart';

import 'navbar.dart';
import 'package:go_router/go_router.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.child,
    this.title,
  });

  final Widget child;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _SideNavDrawer(),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Stack(
              children: [
                Positioned(
                  right: -70,
                  top: -50,
                  child: Container(
                    width: 240,
                    height: 240,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0EA5E9).withValues(alpha: 0.10),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  left: -80,
                  bottom: -90,
                  child: Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F766E).withValues(alpha: 0.10),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const TopNavBar(),
                      const SizedBox(height: 20),
                      if (title != null)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: Text(
                              title!,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      Expanded(child: child),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Sidebar Drawer widget for navigation
class _SideNavDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            ),
            child: const Text(
              'AI Rent Advisor',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          _DrawerNavItem(
            label: 'Analyse',
            path: '/input',
            active: location == '/input' || location == '/result',
            icon: Icons.analytics,
          ),
          _DrawerNavItem(
            label: 'Compare',
            path: '/compare',
            active: location == '/compare',
            icon: Icons.compare_arrows,
          ),
          _DrawerNavItem(
            label: 'About',
            path: '/about',
            active: location == '/about',
            icon: Icons.info_outline,
          ),
          _DrawerNavItem(
            label: 'Profile',
            path: '/profile',
            active: location == '/profile',
            icon: Icons.person_outline,
          ),
        ],
      ),
    );
  }
}

class _DrawerNavItem extends StatelessWidget {
  final String label;
  final String path;
  final bool active;
  final IconData icon;

  const _DrawerNavItem({
    required this.label,
    required this.path,
    required this.active,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon,
          color: active ? Theme.of(context).colorScheme.primary : null),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: active ? FontWeight.bold : FontWeight.normal,
          color: active ? Theme.of(context).colorScheme.primary : null,
        ),
      ),
      selected: active,
      onTap: () {
        Navigator.of(context).pop();
        context.go(path);
      },
    );
  }
}
