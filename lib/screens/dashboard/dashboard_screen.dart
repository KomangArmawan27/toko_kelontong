import 'package:flutter/material.dart';

import '../../services/api_client.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/dashboard_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final client = ApiClient.instance;

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
              title: client.isCustomer ? 'Shop Items' : 'Items',
              icon: Icons.category,
              onTap: () => Navigator.pushNamed(context, '/items'),
            ),
            if (client.canManageStockMovements)
              DashboardCard(
                title: 'Stock',
                icon: Icons.inventory,
                onTap: () => Navigator.pushNamed(context, '/stock'),
              ),
            if (client.canManageCashTransactions)
              DashboardCard(
                title: 'Cash',
                icon: Icons.attach_money,
                onTap: () => Navigator.pushNamed(context, '/cash'),
              ),
            if (client.isShopOwner)
              DashboardCard(
                title: 'Users',
                icon: Icons.people,
                onTap: () => Navigator.pushNamed(context, '/users'),
              ),
            if (client.canViewReports)
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
