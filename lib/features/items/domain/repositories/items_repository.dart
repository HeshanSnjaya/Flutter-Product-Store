import '../entities/item.dart';

abstract class ItemsRepository {
  Future<List<Item>> getAllItems();
  
  Future<List<Item>> getFilteredItems({
    String? category,
    String? subCategory,
  });
  
  Future<bool> checkHealth();
}
