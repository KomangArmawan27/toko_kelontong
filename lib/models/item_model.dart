class ItemModel {
  final int? id;
  final String sku;
  final String name;
  final String description;
  final String unit;
  final double purchasePrice;
  final double sellingPrice;
  final int currentStock;
  final int minimumStock;
  final bool isActive;

  ItemModel({
    this.id,
    required this.sku,
    required this.name,
    required this.description,
    required this.unit,
    required this.purchasePrice,
    required this.sellingPrice,
    required this.currentStock,
    required this.minimumStock,
    this.isActive = true,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      id: _asInt(json['id']),
      sku: (json['sku'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      unit: (json['unit'] ?? '').toString(),
      purchasePrice: _asDouble(json['purchase_price']),
      sellingPrice: _asDouble(json['selling_price']),
      currentStock: _asInt(json['current_stock']) ?? 0,
      minimumStock: _asInt(json['minimum_stock']) ?? 0,
      isActive: _asBool(json['is_active']),
    );
  }

  Map<String, dynamic> toJson() => {
        'sku': sku,
        'name': name,
        'description': description,
        'unit': unit,
        'purchase_price': purchasePrice,
        'selling_price': sellingPrice,
        'current_stock': currentStock.toString(),
        'minimum_stock': minimumStock.toString(),
        'is_active': isActive,
      };
}

int? _asInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  final text = value?.toString() ?? '';
  return int.tryParse(text) ?? double.tryParse(text)?.toInt();
}

double _asDouble(Object? value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

bool _asBool(Object? value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  final text = value?.toString().toLowerCase();
  return text == null || text == 'true' || text == '1';
}
