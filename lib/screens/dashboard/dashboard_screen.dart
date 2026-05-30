import 'package:flutter/material.dart';
import '../../widgets/dashboard_card.dart';
import '../../widgets/app_drawer.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Toko Kelontong'),
      ),

      drawer: const AppDrawer(),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            DashboardCard(
              title: 'Stock',
              icon: Icons.inventory,
              onTap: () => Navigator.pushNamed(context, '/stock'),
            ),

            DashboardCard(
              title: 'Cash',
              icon: Icons.attach_money,
              onTap: () => Navigator.pushNamed(context, '/cash'),
            ),

            DashboardCard(
              title: 'Master Item',
              icon: Icons.category,
              onTap: () => Navigator.pushNamed(context, '/items'),
            ),

            DashboardCard(
              title: 'Reports',
              icon: Icons.bar_chart,
              onTap: () => Navigator.pushNamed(context, '/reports'),
            ),
          ],
        ),
      ),
    );
  }
}
