import 'package:flutter/material.dart';

import '../../models/cash_model.dart';
import '../../services/api_client.dart';
import '../../services/api_data.dart';
import '../../widgets/app_drawer.dart';

class CashManagementScreen extends StatefulWidget {
  const CashManagementScreen({super.key});

  @override
  State<CashManagementScreen> createState() => _CashManagementScreenState();
}

class _CashManagementScreenState extends State<CashManagementScreen> {
  List<CashTransaction> _transactions = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<List<CashTransaction>> _load() async {
    final response = await ApiClient.instance.get('api/cash-transactions');
    return dataList(response).map(CashTransaction.fromJson).toList();
  }

  Future<void> _refresh() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final transactions = await _load();
      if (!mounted) return;
      setState(() {
        _transactions = transactions;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _openForm([CashTransaction? transaction]) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => _CashFormDialog(transaction: transaction),
    );
    if (saved == true) {
      await _refresh();
    }
  }

  Future<void> _delete(CashTransaction transaction) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete cash record?'),
        content: Text(transaction.description.isEmpty
            ? 'This record will be removed.'
            : transaction.description),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true || transaction.id == null) return;
    try {
      await ApiClient.instance.delete('api/cash-transactions/${transaction.id}');
      await _refresh();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cash Management')),
      drawer: const AppDrawer(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add),
        label: const Text('Add Cash'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return _ErrorState(message: _error!, onRetry: _refresh);
    }
    if (_transactions.isEmpty) {
      return const Center(child: Text('No cash records yet.'));
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _transactions.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final item = _transactions[index];
          final isIncome = item.isCashIn;
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: isIncome ? Colors.green[100] : Colors.red[100],
                child: Icon(
                  isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                  color: isIncome ? Colors.green : Colors.red,
                ),
              ),
              title: Text(
                item.description.isEmpty ? item.displayType : item.description,
              ),
              subtitle: Text(item.transactionDate == null
                  ? item.displayType
                  : '${item.displayType} - ${_date(item.transactionDate!)}'),
              trailing: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(_money(item.amount)),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _openForm(item),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _delete(item),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CashFormDialog extends StatefulWidget {
  final CashTransaction? transaction;

  const _CashFormDialog({this.transaction});

  @override
  State<_CashFormDialog> createState() => _CashFormDialogState();
}

class _CashFormDialogState extends State<_CashFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _descriptionController;
  late String _type;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final transaction = widget.transaction;
    _type = transaction?.type ?? CashTransaction.cashIn;
    _amountController = TextEditingController(
      text: transaction == null ? '' : transaction.amount.toString(),
    );
    _descriptionController = TextEditingController(
      text: transaction?.description ?? '',
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final payload = CashTransaction(
      type: _type,
      amount: double.parse(_amountController.text),
      description: _descriptionController.text.trim(),
      transactionDate: DateTime.now(),
    ).toJson();

    try {
      final id = widget.transaction?.id;
      if (id == null) {
        await ApiClient.instance.post('api/cash-transactions', payload);
      } else {
        await ApiClient.instance.put('api/cash-transactions/$id', payload);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.transaction == null ? 'Add Cash Record' : 'Edit Cash Record'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: CashTransaction.cashIn,
                  label: Text('Income'),
                ),
                ButtonSegment(
                  value: CashTransaction.cashOut,
                  label: Text('Expense'),
                ),
              ],
              selected: {_type},
              onSelectionChanged: (value) => setState(() => _type = value.first),
            ),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
              validator: (value) =>
                  double.tryParse(value ?? '') == null ? 'Enter valid amount' : null,
            ),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              validator: (value) => value == null || value.isEmpty
                  ? 'Description is required'
                  : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

String _date(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

String _money(double value) => 'Rp ${value.toStringAsFixed(0)}';
