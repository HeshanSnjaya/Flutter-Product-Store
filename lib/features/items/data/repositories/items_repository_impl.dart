import '../../domain/entities/item.dart';
import '../../domain/repositories/items_repository.dart';
import '../datasources/items_remote_datasource.dart';

class ItemsRepositoryImpl implements ItemsRepository {
  final ItemsRemoteDataSource remoteDataSource;

  const ItemsRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Item>> getAllItems() async {
    try {
      final itemModels = await remoteDataSource.getAllItems();
      return itemModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Repository: Failed to get all items - $e');
    }
  }

  @override
  Future<List<Item>> getFilteredItems({
    String? category,
    String? subCategory,
  }) async {
    try {
      final itemModels = await remoteDataSource.getFilteredItems(
        category: category,
        subCategory: subCategory,
      );
      return itemModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Repository: Failed to filter items - $e');
    }
  }

  @override
  Future<bool> checkHealth() async {
    try {
      return await remoteDataSource.checkHealth();
    } catch (_) {
      return false;
    }
  }
}
