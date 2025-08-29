import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/items_remote_datasource.dart';
import '../../data/repositories/items_repository_impl.dart';
import '../../domain/entities/item.dart';
import '../../domain/usecases/filter_items.dart';
import '../../domain/usecases/get_all_items.dart';

final itemsRemoteDataSourceProvider = Provider(
  (ref) => ItemsRemoteDataSourceImpl(),
);

final itemsRepositoryProvider = Provider(
  (ref) => ItemsRepositoryImpl(ref.watch(itemsRemoteDataSourceProvider)),
);

final getAllItemsUseCaseProvider = Provider(
  (ref) => GetAllItems(ref.watch(itemsRepositoryProvider)),
);

final filterItemsUseCaseProvider = Provider(
  (ref) => FilterItems(ref.watch(itemsRepositoryProvider)),
);

final healthCheckProvider = FutureProvider((ref) async {
  final repository = ref.watch(itemsRepositoryProvider);
  return await repository.checkHealth();
});

final filterStateProvider = StateProvider((ref) {
  return const FilterState();
});

final categoriesProvider = Provider<List<String>>((ref) {
  return ['books', 'clothing', 'electronics', 'fitness', 'sports', 'toys', 'furniture', 'food'];
});

final subCategoriesByCategoryProvider = Provider<Map<String, List<String>>>((ref) {
  return {
    'books': ['business', 'fantasy', 'classic', 'non-fiction'],
    'clothing': ['casual', 'formal', 'sports'],
    'electronics': ['mobile', 'laptop', 'tablet', 'wearable'],
    'fitness': ['recovery', 'equipment', 'supplements'],
    'sports': ['outdoor', 'indoor', 'equipment'],
    'toys': ['board games', 'action figures', 'puzzles'],
    'furniture': ['living room', 'bedroom', 'office'],
    'food': ['snacks', 'beverages', 'organic']
  };
});

final itemsProvider = FutureProvider<List<Item>>((ref) async {
  final filterState = ref.watch(filterStateProvider);
  if (filterState.hasFilters) {
    final filterUseCase = ref.watch(filterItemsUseCaseProvider);
    return await filterUseCase(
      category: filterState.category.isEmpty ? null : filterState.category,
      subCategory: filterState.subCategory.isEmpty ? null : filterState.subCategory,
    );
  } else {
    final getAllUseCase = ref.watch(getAllItemsUseCaseProvider);
    return await getAllUseCase();
  }
});

class FilterState {
  final String category;
  final String subCategory;
  final String search;

  const FilterState({
    this.category = '',
    this.subCategory = '',
    this.search = '',
  });

  bool get hasFilters => category.trim().isNotEmpty || 
                        subCategory.trim().isNotEmpty || 
                        search.trim().isNotEmpty;

  bool get isEmpty => !hasFilters;

  FilterState copyWith({
    String? category,
    String? subCategory,
    String? search,
  }) {
    return FilterState(
      category: category ?? this.category,
      subCategory: subCategory ?? this.subCategory,
      search: search ?? this.search,
    );
  }

  FilterState clear() {
    return const FilterState();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FilterState &&
           other.category == category &&
           other.subCategory == subCategory &&
           other.search == search;
  }

  @override
  int get hashCode => category.hashCode ^ subCategory.hashCode ^ search.hashCode;

  @override
  String toString() => 'FilterState(category: $category, subCategory: $subCategory, search: $search)';
}
