import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:dio/dio.dart';

import '../../../../core/network/network_exceptions.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../widgets/error_widget.dart';
import '../widgets/item_card.dart';
import '../providers/items_providers.dart';
import '../../domain/entities/item.dart';

class ItemsPage extends ConsumerWidget {
  const ItemsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final healthCheck = ref.watch(healthCheckProvider);
    final items = ref.watch(itemsProvider);
    final filterState = ref.watch(filterStateProvider);

    final String bgImage = _backgroundForCategory(filterState.category);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: _buildAppBar(context, ref),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              child: DecoratedBox(
                key: ValueKey(bgImage),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(bgImage),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          // Readability overlay (reduced alpha for better visibility)
          Positioned.fill(
            child: Container(
              color: Theme.of(context)
                  .colorScheme
                  .surface
                  .withValues(alpha: 0.55), // Reduced from 0.72 for better image visibility
            ),
          ),
          Column(
            children: [
              _buildHeaderStrip(context, ref, healthCheck),
              Expanded(
                child: _buildItemsContent(context, ref, items, filterState),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(context, ref),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, WidgetRef ref) {
    return AppBar(
      elevation: 0,
      centerTitle: true,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .primary
                  .withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.store_rounded,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Thrive360 Store',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3,
                ),
          ),
        ],
      ),
      actions: [
        IconButton(
          tooltip: 'Refresh',
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .primary
                  .withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.refresh_rounded,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          onPressed: () => _refreshData(context, ref),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildHeaderStrip(
      BuildContext context, WidgetRef ref, AsyncValue<bool> healthCheck) {
    return Material(
      elevation: 0,
      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.06),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Column(
            children: [
              _buildHealthBanner(healthCheck)
                  .animate()
                  .fadeIn(duration: 300.ms),
              const SizedBox(height: 8),
              const _FilterBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHealthBanner(AsyncValue<bool> healthCheck) {
    return healthCheck.when(
      data: (isHealthy) {
        if (!isHealthy) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.amber.shade700,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Service warming up: first request may take longer.',
                    style: TextStyle(
                      color: Colors.amber.shade800,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
      loading: () => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Row(
          children: [
            SizedBox(
              height: 16,
              width: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.blue.shade600,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Checking service status...',
              style: TextStyle(
                color: Colors.blue.shade700,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      error: (error, _) => const SizedBox.shrink(),
    );
  }

  Widget _buildItemsContent(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<Item>> items,
    FilterState filterState,
  ) {
    return items.when(
      data: (itemsList) {
        if (itemsList.isEmpty) {
          return _buildEmptyState(context, ref, filterState);
        }
        return RefreshIndicator(
          onRefresh: () async => _refreshData(context, ref),
          color: Theme.of(context).colorScheme.primary,
          child: Column(
            children: [
              _buildItemsCountHeader(context, itemsList.length),
              Expanded(child: _buildResponsiveItemsList(context, itemsList)),
            ],
          ),
        );
      },
      loading: () => const LoadingWidget(
        message:
            'Loading items... This may take a moment if the service is starting up.',
        useShimmer: true,
      ),
      error: (error, stackTrace) => _buildErrorState(context, ref, error),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    WidgetRef ref,
    FilterState filterState,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              filterState.hasFilters
                  ? Icons.search_off_rounded
                  : Icons.inventory_2_outlined,
              size: 56,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              filterState.hasFilters ? 'No items found' : 'No items available',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              filterState.hasFilters
                  ? 'Try adjusting filters or clearing them.'
                  : 'Check back later for new items.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7),
                  ),
              textAlign: TextAlign.center,
            ),
            if (filterState.hasFilters) ...[
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () {
                  ref.read(filterStateProvider.notifier).state =
                      const FilterState();
                  ref.invalidate(itemsProvider);
                },
                icon: const Icon(Icons.clear_all_rounded),
                label: const Text('Clear Filters'),
              ),
            ],
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildItemsCountHeader(BuildContext context, int itemCount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .primary
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '$itemCount item${itemCount == 1 ? '' : 's'} found',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.85),
                ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue.shade600,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.shade200.withValues(alpha: 0.5),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              'Updated',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms).slideX(begin: -0.05, end: 0);
  }

  Widget _buildResponsiveItemsList(BuildContext context, List<Item> itemsList) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 900) {
          final crossAxisCount = constraints.maxWidth > 1400 ? 3 : 2;
          return GridView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: 2.8,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: itemsList.length,
            itemBuilder: (context, index) {
              return ItemCard(
                item: itemsList[index],
                index: index,
              );
            },
          );
        }
        return ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: itemsList.length,
          itemBuilder: (context, index) {
            return ItemCard(
              item: itemsList[index],
              index: index,
            );
          },
        );
      },
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, Object error) {
    String errorMessage = 'Failed to load items';
    IconData errorIcon = Icons.error_outline_rounded;

    if (error is Exception) {
      final errorStr = error.toString();
      if (errorStr.contains('DioException')) {
        try {
          final dioError = error as DioException;
          errorMessage = NetworkExceptions.getErrorMessage(dioError);
          if (NetworkExceptions.isNetworkError(dioError)) {
            errorIcon = Icons.wifi_off_rounded;
          }
        } catch (_) {
          errorMessage = 'Network error. Please check your connection.';
          errorIcon = Icons.wifi_off_rounded;
        }
      } else {
        errorMessage = errorStr.replaceFirst('Exception: ', '');
      }
    }

    return CustomErrorWidget(
      message: errorMessage,
      icon: errorIcon,
      onRetry: () => _refreshData(context, ref),
    );
  }

  Widget? _buildFloatingActionButton(BuildContext context, WidgetRef ref) {
    return MediaQuery.of(context).size.width < 600
        ? FloatingActionButton.small(
            onPressed: () => _refreshData(context, ref),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            elevation: 2,
            child: const Icon(Icons.refresh_rounded),
          )
        : null;
  }

  Future<void> _refreshData(BuildContext context, WidgetRef ref) async {
    ref.invalidate(itemsProvider);
    ref.invalidate(healthCheckProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            SizedBox(
              height: 16,
              width: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 12),
            Text('Refreshing data...'),
          ],
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}

// Filter bar widget with fixed layout
class _FilterBar extends ConsumerStatefulWidget {
  const _FilterBar();

  @override
  ConsumerState<_FilterBar> createState() => _FilterBarState();
}

class _FilterBarState extends ConsumerState<_FilterBar> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final state = ref.read(filterStateProvider);
    _searchController.text = state.search;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters({String? category, String? subCategory, String? search}) {
    final current = ref.read(filterStateProvider);
    final next = current.copyWith(
      category: category ?? current.category,
      subCategory: subCategory ?? current.subCategory,
      search: search ?? current.search,
    );
    ref.read(filterStateProvider.notifier).state = next;
    ref.invalidate(itemsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(filterStateProvider);
    final categories = ref.watch(categoriesProvider);
    final subMap = ref.watch(subCategoriesByCategoryProvider);
    final subs = subMap[state.category] ?? const <String>[];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 720;

        final categoryWidget = _DropdownBox<String>(
          label: 'Category',
          value: state.category.isEmpty ? null : state.category,
          items: categories,
          onChanged: (val) {
            _applyFilters(category: val ?? '', subCategory: '');
          },
          icon: Icons.category_rounded,
        );

        final subcategoryWidget = _DropdownBox<String>(
          label: 'Subcategory',
          value: state.subCategory.isEmpty ? null : state.subCategory,
          items: subs,
          onChanged: (val) => _applyFilters(subCategory: val ?? ''),
          icon: Icons.subdirectory_arrow_right_rounded,
        );

        final searchWidget = TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            labelText: 'Search by category or subcategory',
            hintText: 'e.g., laptop, mobile, board games',
            prefixIcon: Icon(Icons.search),
          ),
          textInputAction: TextInputAction.search,
          onSubmitted: (v) => _applyFilters(search: v.trim()),
        );

        final clearButton = OutlinedButton.icon(
          onPressed: state.hasFilters
              ? () {
                  _searchController.clear();
                  _applyFilters(category: '', subCategory: '', search: '');
                }
              : null,
          icon: const Icon(Icons.clear_all),
          label: const Text('Clear'),
        );

        if (isWide) {
          // Use Row for wide screens with Flexible
          return Row(
            children: [
              Flexible(flex: 2, child: categoryWidget),
              const SizedBox(width: 12),
              if (state.category.isNotEmpty)
                Flexible(flex: 2, child: subcategoryWidget),
              if (state.category.isNotEmpty) const SizedBox(width: 12),
              Flexible(flex: 3, child: searchWidget),
              const SizedBox(width: 12),
              ConstrainedBox(
                constraints:
                    const BoxConstraints(minWidth: 100, maxWidth: 150),
                child: clearButton,
              ),
            ],
          );
        }

        // Use Wrap for narrow screens with SizedBox
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(width: constraints.maxWidth, child: categoryWidget),
            if (state.category.isNotEmpty)
              SizedBox(width: constraints.maxWidth, child: subcategoryWidget),
            SizedBox(width: constraints.maxWidth, child: searchWidget),
            SizedBox(width: 160, child: clearButton),
          ],
        );
      },
    );
  }
}

class _DropdownBox<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<T> items;
  final void Function(T?) onChanged;
  final IconData icon;

  const _DropdownBox({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyMedium;
    return DropdownButtonFormField<T>(
      isExpanded: true,
      value: value,
      items: items
          .map((e) => DropdownMenuItem<T>(
                value: e,
                child: Text(
                  e.toString(),
                  overflow: TextOverflow.ellipsis,
                  style: textStyle,
                ),
              ))
          .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
    );
  }
}

String _backgroundForCategory(String category) {
  switch (category.toLowerCase()) {
    case 'electronics':
      return 'assets/images/bg_electronics.jpg';
    case 'books':
      return 'assets/images/bg_books.jpg';
    case 'clothing':
      return 'assets/images/bg_clothing.jpg';
    case 'sports':
      return 'assets/images/bg_sports.jpg';
    case 'toys':
      return 'assets/images/bg_toys.jpg';
    case 'furniture':
      return 'assets/images/bg_furniture.jpg';
    case 'food':
      return 'assets/images/bg_food.jpg';
    case 'fitness':
      return 'assets/images/bg_fitness.jpg';
    default:
      return 'assets/images/bg_default.jpg';
  }
}
