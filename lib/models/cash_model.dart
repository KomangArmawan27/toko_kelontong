class CashTransaction {
  static const String cashIn = 'cash_in';
  static const String cashOut = 'cash_out';

  final int? id;
  final String type;
  final double amount;
  final String description;
  final DateTime? transactionDate;

  CashTransaction({
    this.id,
    required this.type,
    required this.amount,
    required this.description,
    this.transactionDate,
  });

  factory CashTransaction.fromJson(Map<String, dynamic> json) {
    return CashTransaction(
      id: _asInt(json['id']),
      type: normalizeType(json['type'] ?? json['transaction_type']),
      amount: _asDouble(json['amount']),
      description: (json['description'] ?? json['note'] ?? '').toString(),
      transactionDate: DateTime.tryParse(
        (json['transaction_date'] ?? json['date'] ?? '').toString(),
      ),
    );
  }

  bool get isCashIn => type == cashIn;

  String get displayType => isCashIn ? 'Income' : 'Expense';

  Map<String, dynamic> toJson() => {
        'type': normalizeType(type),
        'amount': amount,
        'description': description,
        if (transactionDate != null)
          'transaction_date': transactionDate!.toIso8601String().split('T').first,
      };

  static String normalizeType(Object? value) {
    final text = value?.toString().toLowerCase();
    if (text == cashOut || text == 'expense' || text == 'out') {
      return cashOut;
    }
    return cashIn;
  }
}

int? _asInt(Object? value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '');
}

double _asDouble(Object? value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}
