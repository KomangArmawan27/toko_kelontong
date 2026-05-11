class ItemModel {
  final int? id;
  final String name;
  final String category;
  final int stock;
  final double buyPrice;
  final double sellPrice;

  ItemModel({
    this.id,
    required this.name,
    required this.category,
    required this.stock,
    required this.buyPrice,
    required this.sellPrice,
  });
}