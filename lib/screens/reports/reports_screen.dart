import 'package:flutter/material.dart';

import '../../models/cash_model.dart';
import '../../models/item_model.dart';
import '../../models/stock_model.dart';
import '../../services/api_client.dart';
import '../../services/api_data.dart';
import '../../widgets/app_drawer.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  late Future<_ReportData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_ReportData> _load() async {
    final cashResponse = await ApiClient.instance.get('api/cash-transactions');
    final itemResponse = await ApiClient.instance.get('api/items');
    final stockResponse = await ApiClient.instance.get('api/stock-movements');

    return _ReportData(
      cash: dataList(cashResponse).map(CashTransaction.fromJson).toList(),
      items: dataList(itemResponse).map(ItemModel.fromJson).toList(),
      stock: dataList(stockResponse).map(StockMovement.fromJson).toList(),
    );
  }

  void _refresh() {
    setState(() => _future = _load());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      drawer: const AppDrawer(),
      body: FutureBuilder<_ReportData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(snapshot.error.toString()),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: _refresh,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final data = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async => _refresh(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _ReportCard(
                      title: 'Cash Balance',
                      value: 'Rp ${data.balance.toStringAsFixed(0)}',
                      icon: Icons.account_balance_wallet,
                    ),
                    _ReportCard(
                      title: 'Income',
                      value: 'Rp ${data.income.toStringAsFixed(0)}',
                      icon: Icons.trending_up,
                    ),
                    _ReportCard(
                      title: 'Expense',
                      value: 'Rp ${data.expense.toStringAsFixed(0)}',
                      icon: Icons.trending_down,
                    ),
                    _ReportCard(
                      title: 'Total Items',
                      value: data.items.length.toString(),
                      icon: Icons.category,
                    ),
                    _ReportCard(
                      title: 'Stock Movements',
                      value: data.stock.length.toString(),
                      icon: Icons.inventory,
                    ),
                    _ReportCard(
                      title: 'Stock Value',
                      value: 'Rp ${data.stockValue.toStringAsFixed(0)}',
                      icon: Icons.point_of_sale,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Low Stock',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                ...data.lowStock.map(
                  (item) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.warning_amber),
                      title: Text(item.name),
                      subtitle: Text(
                        '${item.sku} - Stock ${item.currentStock}/${item.minimumStock}',
                      ),
                    ),
                  ),
                ),
                if (data.lowStock.isEmpty)
                  const Card(
                    child: ListTile(title: Text('No low stock items.')),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _ReportCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: Colors.green),
              const SizedBox(height: 12),
              Text(title),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReportData {
  final List<CashTransaction> cash;
  final List<ItemModel> items;
  final List<StockMovement> stock;

  _ReportData({
    required this.cash,
    required this.items,
    required this.stock,
  });

  double get income => cash
      .where((item) => item.isCashIn)
      .fold(0.0, (sum, item) => sum + item.amount);

  double get expense => cash
      .where((item) => !item.isCashIn)
      .fold(0.0, (sum, item) => sum + item.amount);

  double get balance => income - expense;

  double get stockValue {
    return items.fold(
      0.0,
      (sum, item) => sum + (item.currentStock * item.purchasePrice),
    );
  }

  List<ItemModel> get lowStock {
    return items
        .where((item) => item.currentStock <= item.minimumStock)
        .toList();
  }
}
