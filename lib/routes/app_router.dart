import 'package:flutter/material.dart';

import '../screens/access_denied_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/cash/cash_management_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/items/item_master_screen.dart';
import '../screens/reports/reports_screen.dart';
import '../screens/stock/stock_management_screen.dart';
import '../screens/users/users_management_screen.dart';
import '../services/api_client.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final client = ApiClient.instance;

    switch (settings.name) {
      case '/login':
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );

      case '/register':
        return MaterialPageRoute(
          builder: (_) => const RegisterScreen(),
          settings: settings,
        );

      case '/':
        return MaterialPageRoute(
          builder: (_) => const DashboardScreen(),
          settings: settings,
        );

      case '/cash':
        return MaterialPageRoute(
          builder: (_) => client.canManageCashTransactions
              ? const CashManagementScreen()
              : const AccessDeniedScreen(
                  message: 'Cash management is only available for the shop owner and shop keeper.',
                ),
          settings: settings,
        );

      case '/stock':
        return MaterialPageRoute(
          builder: (_) => client.canManageStockMovements
              ? const StockManagementScreen()
              : const AccessDeniedScreen(
                  message: 'Stock management is only available for the shop owner and shop keeper.',
                ),
          settings: settings,
        );

      case '/items':
        return MaterialPageRoute(
          builder: (_) => const ItemMasterScreen(),
          settings: settings,
        );

      case '/users':
        return MaterialPageRoute(
          builder: (_) => client.isShopOwner
              ? const UsersManagementScreen()
              : const AccessDeniedScreen(
                  message: 'User management is only available for the shop owner.',
                ),
          settings: settings,
        );

      case '/reports':
        return MaterialPageRoute(
          builder: (_) => client.canViewReports
              ? const ReportsScreen()
              : const AccessDeniedScreen(
                  message: 'Reports are only available for the shop owner.',
                ),
          settings: settings,
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Page Not Found'),
            ),
          ),
        );
    }
  }
}
