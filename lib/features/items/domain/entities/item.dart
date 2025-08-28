class Item {
  final String id;
  final String name;
  final String brand;
  final String category;
  final String subCategory;

  const Item({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    required this.subCategory,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Item &&
        other.id == id &&
        other.name == name &&
        other.brand == brand &&
        other.category == category &&
        other.subCategory == subCategory;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        brand.hashCode ^
        category.hashCode ^
        subCategory.hashCode;
  }

  @override
  String toString() {
    return 'Item(id: $id, name: $name, brand: $brand, category: $category, subCategory: $subCategory)';
  }
}
