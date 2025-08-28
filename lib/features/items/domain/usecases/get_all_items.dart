import '../entities/item.dart';
import '../repositories/items_repository.dart';

class GetAllItems {
  final ItemsRepository repository;

  const GetAllItems(this.repository);

  Future<List<Item>> call() async {
    try {
      return await repository.getAllItems();
    } catch (e) {
      rethrow;
    }
  }
}
