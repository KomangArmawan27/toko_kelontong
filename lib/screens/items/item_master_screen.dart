import 'package:flutter/material.dart';

import '../../models/item_model.dart';
import '../../services/api_client.dart';
import '../../services/api_data.dart';
import '../../widgets/app_drawer.dart';

class ItemMasterScreen extends StatefulWidget {
  const ItemMasterScreen({super.key});

  @override
  State<ItemMasterScreen> createState() => _ItemMasterScreenState();
}

class _ItemMasterScreenState extends State<ItemMasterScreen> {
  List<ItemModel> _items = [];
  bool _isLoading = true;
  String? _error;

  bool get _canManageItems => ApiClient.instance.canManageItems;

  bool get _canPurchaseItems => ApiClient.instance.canPurchaseItems;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  String get _title {
    if (_canManageItems) return 'Master Item';
    if (_canPurchaseItems) return 'Shop Items';
    return 'Items';
  }

  Future<List<ItemModel>> _load() async {
    final response = await ApiClient.instance.get('api/items');
    return dataList(response).map(ItemModel.fromJson).toList();
  }

  Future<void> _refresh() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final items = await _load();
      if (!mounted) return;
      setState(() {
        _items = items;
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

  Future<void> _openForm([ItemModel? item]) async {
    if (!_canManageItems) return;
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => _ItemFormDialog(item: item),
    );
    if (saved == true) {
      await _refresh();
    }
  }

  Future<void> _purchase(ItemModel item) async {
    if (!ApiClient.instance.canPurchaseItems || item.id == null) return;

    final request = await showDialog<_PurchaseRequest>(
      context: context,
      builder: (_) => _PurchaseDialog(item: item),
    );
    if (request == null) return;

    try {
      final response = await ApiClient.instance.purchaseItem(
        item.id!,
        quantity: request.quantity,
        notes: request.notes,
      );
      final totalAmount = _asDouble(dataMap(response)['total_amount']);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Purchase completed for Rp ${totalAmount.toStringAsFixed(0)}')),
      );
      await _refresh();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
      }
    }
  }

  Future<void> _delete(ItemModel item) async {
    if (!_canManageItems) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete item?'),
        content: Text(item.name),
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

    if (confirm != true || item.id == null) return;
    try {
      await ApiClient.instance.delete('api/items/${item.id}');
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
      appBar: AppBar(title: Text(_title)),
      drawer: const AppDrawer(),
      floatingActionButton: _canManageItems
          ? FloatingActionButton.extended(
              onPressed: () => _openForm(),
              icon: const Icon(Icons.add),
              label: const Text('Add Item'),
            )
          : null,
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
    if (_items.isEmpty) {
      return const Center(child: Text('No items yet.'));
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _items.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final item = _items[index];
          return Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.category)),
              title: Text(item.name),
              subtitle: Text(
                '${item.sku} - ${item.unit} - Stock ${_formatQuantity(item.currentStock)}',
              ),
              trailing: _buildTrailing(item),
            ),
          );
        },
      ),
    );
  }

  Widget? _buildTrailing(ItemModel item) {
    if (_canManageItems) {
      return Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text('Rp ${item.sellingPrice.toStringAsFixed(0)}'),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _openForm(item),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _delete(item),
          ),
        ],
      );
    }

    if (_canPurchaseItems) {
      return IconButton(
        tooltip: 'Purchase',
        icon: const Icon(Icons.shopping_cart_checkout),
        onPressed: () => _purchase(item),
      );
    }

    return Text('Rp ${item.sellingPrice.toStringAsFixed(0)}');
  }
}

class _ItemFormDialog extends StatefulWidget {
  final ItemModel? item;

  const _ItemFormDialog({this.item});

  @override
  State<_ItemFormDialog> createState() => _ItemFormDialogState();
}

class _ItemFormDialogState extends State<_ItemFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _skuController;
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _unitController;
  late final TextEditingController _purchasePriceController;
  late final TextEditingController _sellingPriceController;
  late final TextEditingController _minimumStockController;
  late bool _isActive;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _skuController = TextEditingController(text: item?.sku ?? '');
    _nameController = TextEditingController(text: item?.name ?? '');
    _descriptionController = TextEditingController(
      text: item?.description ?? '',
    );
    _unitController = TextEditingController(text: item?.unit ?? 'pcs');
    _purchasePriceController = TextEditingController(
      text: item == null ? '' : item.purchasePrice.toString(),
    );
    _sellingPriceController = TextEditingController(
      text: item == null ? '' : item.sellingPrice.toString(),
    );
    _minimumStockController = TextEditingController(
      text: item == null ? '0' : item.minimumStock.toString(),
    );
    _isActive = item?.isActive ?? true;
  }

  @override
  void dispose() {
    _skuController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _unitController.dispose();
    _purchasePriceController.dispose();
    _sellingPriceController.dispose();
    _minimumStockController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final payload = ItemModel(
      sku: _skuController.text.trim(),
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      unit: _unitController.text.trim(),
      purchasePrice: double.parse(_purchasePriceController.text),
      sellingPrice: double.parse(_sellingPriceController.text),
      currentStock: widget.item?.currentStock ?? 0,
      minimumStock: double.parse(_minimumStockController.text),
      isActive: _isActive,
    ).toJson();

    try {
      final id = widget.item?.id;
      if (id == null) {
        await ApiClient.instance.post('api/items', payload);
      } else {
        await ApiClient.instance.put('api/items/$id', payload);
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
      title: Text(widget.item == null ? 'Add Item' : 'Edit Item'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _requiredField(_skuController, 'SKU'),
              _requiredField(_nameController, 'Name'),
              _requiredField(_descriptionController, 'Description'),
              _requiredField(_unitController, 'Unit'),
              _numberField(_purchasePriceController, 'Purchase Price'),
              _numberField(_sellingPriceController, 'Selling Price'),
              _numberField(_minimumStockController, 'Minimum Stock'),
              const SizedBox(height: 8),
              const Text(
                'Current stock is controlled by stock movements and purchases.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Active'),
                value: _isActive,
                onChanged: (value) => setState(() => _isActive = value),
              ),
            ],
          ),
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

class _PurchaseRequest {
  final double quantity;
  final String notes;

  const _PurchaseRequest({required this.quantity, required this.notes});
}

class _PurchaseDialog extends StatefulWidget {
  final ItemModel item;

  const _PurchaseDialog({required this.item});

  @override
  State<_PurchaseDialog> createState() => _PurchaseDialogState();
}

class _PurchaseDialogState extends State<_PurchaseDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _quantityController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(text: '1');
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      _PurchaseRequest(
        quantity: double.parse(_quantityController.text),
        notes: _notesController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Purchase ${widget.item.name}'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Available stock: ${_formatQuantity(widget.item.currentStock)}',
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _quantityController,
              decoration: const InputDecoration(labelText: 'Quantity'),
              keyboardType: TextInputType.number,
              validator: (value) {
                final quantity = double.tryParse(value ?? '');
                if (quantity == null || quantity <= 0) {
                  return 'Enter a valid quantity';
                }
                if (quantity > widget.item.currentStock) {
                  return 'Quantity exceeds available stock';
                }
                return null;
              },
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
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Purchase'),
        ),
      ],
    );
  }
}

TextFormField _requiredField(TextEditingController controller, String label) {
  return TextFormField(
    controller: controller,
    decoration: InputDecoration(labelText: label),
    validator: (value) =>
        value == null || value.isEmpty ? '$label is required' : null,
  );
}

TextFormField _numberField(TextEditingController controller, String label) {
  return TextFormField(
    controller: controller,
    decoration: InputDecoration(labelText: label),
    keyboardType: TextInputType.number,
    validator: (value) =>
        double.tryParse(value ?? '') == null ? 'Enter valid $label' : null,
  );
}

String _formatQuantity(double value) {
  if (value == value.roundToDouble()) {
    return value.toInt().toString();
  }
  return value.toStringAsFixed(2);
}

double _asDouble(Object? value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}




