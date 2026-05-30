import 'package:flutter/material.dart';

import '../services/api_client.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            child: Text(
              'Toko Kelontong',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          _NavTile(
            icon: Icons.dashboard,
            title: 'Dashboard',
            route: '/',
          ),
          _NavTile(
            icon: Icons.inventory,
            title: 'Stock Management',
            route: '/stock',
          ),
          _NavTile(
            icon: Icons.attach_money,
            title: 'Cash Management',
            route: '/cash',
          ),
          _NavTile(
            icon: Icons.category,
            title: 'Master Item',
            route: '/items',
          ),
          _NavTile(
            icon: Icons.bar_chart,
            title: 'Reports',
            route: '/reports',
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () async {
              await ApiClient.instance.logout();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (_) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String route;

  const _NavTile({
    required this.icon,
    required this.title,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        if (ModalRoute.of(context)?.settings.name != route) {
          Navigator.pushReplacementNamed(context, route);
        }
      },
    );
  }
}
