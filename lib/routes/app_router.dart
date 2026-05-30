import 'package:flutter/material.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/cash/cash_management_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/items/item_master_screen.dart';
import '../screens/reports/reports_screen.dart';
import '../screens/stock/stock_management_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
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
          builder: (_) => const CashManagementScreen(),
          settings: settings,
        );

      case '/stock':
        return MaterialPageRoute(
          builder: (_) => const StockManagementScreen(),
          settings: settings,
        );

      case '/items':
        return MaterialPageRoute(
          builder: (_) => const ItemMasterScreen(),
          settings: settings,
        );

      case '/reports':
        return MaterialPageRoute(
          builder: (_) => const ReportsScreen(),
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
