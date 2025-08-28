import '../entities/item.dart';
import '../repositories/items_repository.dart';

class FilterItems {
  final ItemsRepository repository;

  const FilterItems(this.repository);

  Future<List<Item>> call({
    String? category,
    String? subCategory,
  }) async {
    try {
      return await repository.getFilteredItems(
        category: category?.trim().isEmpty == true ? null : category?.trim(),
        subCategory: subCategory?.trim().isEmpty == true ? null : subCategory?.trim(),
      );
    } catch (e) {
      rethrow;
    }
  }
}
