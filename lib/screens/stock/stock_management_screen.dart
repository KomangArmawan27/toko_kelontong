import 'package:flutter/material.dart';

import '../../models/item_model.dart';
import '../../models/stock_model.dart';
import '../../services/api_client.dart';
import '../../services/api_data.dart';
import '../../widgets/app_drawer.dart';

class StockManagementScreen extends StatefulWidget {
  const StockManagementScreen({super.key});

  @override
  State<StockManagementScreen> createState() => _StockManagementScreenState();
}

class _StockManagementScreenState extends State<StockManagementScreen> {
  List<StockMovement> _movements = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<List<StockMovement>> _load() async {
    final response = await ApiClient.instance.get('api/stock-movements');
    return dataList(response).map(StockMovement.fromJson).toList();
  }

  Future<void> _refresh() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final movements = await _load();
      if (!mounted) return;
      setState(() {
        _movements = movements;
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

  Future<void> _openForm() async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => const _StockFormDialog(),
    );
    if (saved == true) {
      await _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stock Management')),
      drawer: const AppDrawer(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openForm,
        icon: const Icon(Icons.add),
        label: const Text('Add Movement'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!),
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
    if (_movements.isEmpty) {
      return const Center(child: Text('No stock movements yet.'));
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _movements.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final movement = _movements[index];
          final isIn = movement.type.toLowerCase().contains('in');
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: isIn ? Colors.green[100] : Colors.orange[100],
                child: Icon(
                  isIn ? Icons.add_box : Icons.indeterminate_check_box,
                  color: isIn ? Colors.green : Colors.orange,
                ),
              ),
              title: Text(movement.itemName.isEmpty
                  ? 'Item #${movement.itemId ?? '-'}'
                  : movement.itemName),
              subtitle: Text(movement.notes.isEmpty
                  ? movement.type
                  : '${movement.type} - ${movement.notes}'),
              trailing: Text('${isIn ? '+' : '-'}${movement.quantity}'),
            ),
          );
        },
      ),
    );
  }
}

class _StockFormDialog extends StatefulWidget {
  const _StockFormDialog();

  @override
  State<_StockFormDialog> createState() => _StockFormDialogState();
}

class _StockFormDialogState extends State<_StockFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();
  List<ItemModel> _items = [];
  int? _itemId;
  String _type = 'in';
  bool _loadingItems = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadItems() async {
    try {
      final response = await ApiClient.instance.get('api/items');
      final items = dataList(response).map(ItemModel.fromJson).toList();
      setState(() {
        _items = items;
        _itemId = items.isEmpty ? null : items.first.id;
        _loadingItems = false;
      });
    } catch (_) {
      setState(() => _loadingItems = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _itemId == null) return;
    setState(() => _saving = true);

    final selectedItem = _items.firstWhere((item) => item.id == _itemId);
    final quantity = int.parse(_quantityController.text);
    final stockBefore = selectedItem.currentStock;
    final stockAfter = _type == 'in'
        ? stockBefore + quantity
        : stockBefore - quantity;

    final payload = StockMovement(
      itemId: _itemId,
      itemName: '',
      type: _type,
      quantity: quantity,
      stockBefore: stockBefore,
      stockAfter: stockAfter,
      notes: _notesController.text.trim(),
      occurredAt: DateTime.now(),
    ).toJson();

    try {
      await ApiClient.instance.post('api/stock-movements', payload);
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
      title: const Text('Add Stock Movement'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_loadingItems)
              const Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              )
            else
              DropdownButtonFormField<int>(
                value: _itemId,
                decoration: const InputDecoration(labelText: 'Item'),
                items: _items
                    .where((item) => item.id != null)
                    .map(
                      (item) => DropdownMenuItem(
                        value: item.id,
                        child: Text(item.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _itemId = value),
                validator: (value) => value == null ? 'Choose item' : null,
              ),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'in', label: Text('In')),
                ButtonSegment(value: 'out', label: Text('Out')),
              ],
              selected: {_type},
              onSelectionChanged: (value) => setState(() => _type = value.first),
            ),
            TextFormField(
              controller: _quantityController,
              decoration: const InputDecoration(labelText: 'Quantity'),
              keyboardType: TextInputType.number,
              validator: (value) =>
                  int.tryParse(value ?? '') == null ? 'Enter valid quantity' : null,
            ),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Notes'),
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
