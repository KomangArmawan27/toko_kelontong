import 'package:flutter/material.dart';
import '../../widgets/dashboard_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Toko Kelontong'),
      ),

      drawer: Drawer(
        child: ListView(
          children: const [
            DrawerHeader(
              child: Text(
                'Menu',
                style: TextStyle(fontSize: 24),
              ),
            ),

            ListTile(
              leading: Icon(Icons.dashboard),
              title: Text('Dashboard'),
            ),

            ListTile(
              leading: Icon(Icons.inventory),
              title: Text('Stock Management'),
            ),

            ListTile(
              leading: Icon(Icons.attach_money),
              title: Text('Cash Management'),
            ),

            ListTile(
              leading: Icon(Icons.category),
              title: Text('Master Item'),
            ),
          ],
        ),
      ),

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
              onTap: () {},
            ),

            DashboardCard(
              title: 'Cash',
              icon: Icons.attach_money,
              onTap: () {},
            ),

            DashboardCard(
              title: 'Master Item',
              icon: Icons.category,
              onTap: () {},
            ),

            DashboardCard(
              title: 'Reports',
              icon: Icons.bar_chart,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}