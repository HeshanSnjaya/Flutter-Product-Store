import '../../domain/entities/item.dart';

class ItemModel {
  final String id;
  final String name;
  final String brand;
  final String category;
  final String subCategory;
  final double price;

  const ItemModel({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    required this.subCategory,
    required this.price,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      id: _safeString(json['id']),
      name: _safeString(json['name']),
      brand: _safeString(json['brand']),
      // Handle both "category" and "categiry" (API typo)
      category: _safeString(json['category'] ?? json['categiry']),
      subCategory: _safeString(json['subCategory']),
      price: _parsePrice(json['price']),
    );
  }

  static String _safeString(dynamic value) {
    if (value == null) return 'Unknown';
    return value.toString();
  }

  static double _parsePrice(dynamic price) {
    if (price == null) return 0.0;
    if (price is double) return price;
    if (price is int) return price.toDouble();
    if (price is String) return double.tryParse(price) ?? 0.0;
    return 0.0;
  }

  Item toEntity() {
    return Item(
      id: id,
      name: name,
      brand: brand,
      category: category,
      subCategory: subCategory,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'category': category,
      'subCategory': subCategory,
      'price': price,
    };
  }
}
