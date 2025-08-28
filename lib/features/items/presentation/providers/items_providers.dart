import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/items_remote_datasource.dart';
import '../../data/repositories/items_repository_impl.dart';
import '../../domain/entities/item.dart';
import '../../domain/repositories/items_repository.dart';
import '../../domain/usecases/filter_items.dart';
import '../../domain/usecases/get_all_items.dart';

// Data Source Provider
final itemsRemoteDataSourceProvider = Provider<ItemsRemoteDataSource>(
  (ref) => ItemsRemoteDataSourceImpl(),
);

// Repository Provider
final itemsRepositoryProvider = Provider<ItemsRepository>(
  (ref) => ItemsRepositoryImpl(ref.watch(itemsRemoteDataSourceProvider)),
);

// Use Cases Providers
final getAllItemsUseCaseProvider = Provider<GetAllItems>(
  (ref) => GetAllItems(ref.watch(itemsRepositoryProvider)),
);

final filterItemsUseCaseProvider = Provider<FilterItems>(
  (ref) => FilterItems(ref.watch(itemsRepositoryProvider)),
);

// Health Check Provider
final healthCheckProvider = FutureProvider<bool>((ref) async {
  final repository = ref.watch(itemsRepositoryProvider);
  return await repository.checkHealth();
});

// Filter State Provider
final filterStateProvider = StateProvider<FilterState>((ref) {
  return const FilterState();
});

// Items Provider with automatic refresh based on filter state
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

// Filter State Class
class FilterState {
  final String category;
  final String subCategory;

  const FilterState({
    this.category = '',
    this.subCategory = '',
  });

  bool get hasFilters => category.trim().isNotEmpty || subCategory.trim().isNotEmpty;

  bool get isEmpty => !hasFilters;

  FilterState copyWith({
    String? category,
    String? subCategory,
  }) {
    return FilterState(
      category: category ?? this.category,
      subCategory: subCategory ?? this.subCategory,
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
        other.subCategory == subCategory;
  }

  @override
  int get hashCode => category.hashCode ^ subCategory.hashCode;

  @override
  String toString() => 'FilterState(category: $category, subCategory: $subCategory)';
}
