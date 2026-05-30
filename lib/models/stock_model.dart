class StockMovement {
  final int? id;
  final int? itemId;
  final String itemName;
  final String type;
  final int quantity;
  final int stockBefore;
  final int stockAfter;
  final String notes;
  final DateTime? occurredAt;

  StockMovement({
    this.id,
    this.itemId,
    required this.itemName,
    required this.type,
    required this.quantity,
    required this.stockBefore,
    required this.stockAfter,
    required this.notes,
    this.occurredAt,
  });

  factory StockMovement.fromJson(Map<String, dynamic> json) {
    final item = json['item'];
    final itemMap = item is Map<String, dynamic> ? item : null;

    return StockMovement(
      id: _asInt(json['id']),
      itemId: _asInt(json['item_id'] ?? itemMap?['id']),
      itemName: (itemMap?['name'] ?? json['item_name'] ?? '').toString(),
      type: (json['type'] ?? 'in').toString(),
      quantity: _asInt(json['quantity']) ?? 0,
      stockBefore: _asInt(json['stock_before']) ?? 0,
      stockAfter: _asInt(json['stock_after']) ?? 0,
      notes: (json['notes'] ?? '').toString(),
      occurredAt: DateTime.tryParse(
        (json['occurred_at'] ?? '').toString(),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'item_id': itemId,
        'type': type,
        'quantity': quantity,
        'stock_before': stockBefore,
        'stock_after': stockAfter,
        'notes': notes,
        if (occurredAt != null) 'occurred_at': occurredAt!.toIso8601String(),
      };
}

int? _asInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  final text = value?.toString() ?? '';
  return int.tryParse(text) ?? double.tryParse(text)?.toInt();
}
