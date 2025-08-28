import '../entities/item.dart';

abstract class ItemsRepository {
  /// Gets all items from the store
  Future<List<Item>> getAllItems();
  
  /// Gets filtered items based on category and/or subCategory
  Future<List<Item>> getFilteredItems({
    String? category,
    String? subCategory,
  });
  
  /// Checks if the service is healthy and running
  Future<bool> checkHealth();
}
