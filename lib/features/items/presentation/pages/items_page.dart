import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:dio/dio.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

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

    final String bgImageUrl = _getBackgroundImageUrl(filterState.category);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: _buildAppBar(context, ref),
      body: Column(
        children: [
          // UPPER SECTION - Modern blue background with header and filters
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.blue.shade700, // ← CHANGE THIS for gradient top
                  Colors.blue.shade600, // ← CHANGE THIS for gradient bottom
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: Column(
                  children: [
                    _buildHealthBanner(healthCheck)
                        .animate()
                        .fadeIn(duration: 300.ms),
                    const SizedBox(height: 12),
                    const _ModernFilterBar(),
                  ],
                ),
              ),
            ),
          ),
          // LOWER SECTION - Items list with image background
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(bgImageUrl),
                  fit: BoxFit.cover,
                  onError: (exception, stackTrace) {
                    debugPrint('Failed to load background image: $bgImageUrl');
                  },
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1), // ← CHANGE THIS for image overlay
                ),
                child: _buildItemsContent(context, ref, items, filterState),
              ),
            ),
          ),
        ],
      ),
      // No floating action button
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, WidgetRef ref) {
    return AppBar(
      elevation: 0,
      centerTitle: true,
      backgroundColor: const Color.fromARGB(255, 9, 92, 208), // ←app bar color
      foregroundColor: Colors.white,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              FluentIcons.store_microsoft_20_filled,
              size: 22,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Thrive360 Store',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                  color: Colors.white,
                ),
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.15),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            onPressed: () => _refreshData(context, ref),
            icon: Icon(FluentIcons.arrow_clockwise_20_filled, size: 18),
            label: Text(
              'Refresh',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHealthBanner(AsyncValue<bool> healthCheck) {
    return healthCheck.when(
      data: (isHealthy) {
        if (!isHealthy) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.amber.shade300, width: 2),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    FluentIcons.warning_20_filled,
                    color: Colors.amber.shade700,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Service warming up: first request may take longer.',
                    style: TextStyle(
                      color: Colors.amber.shade800,
                      fontSize: 14,
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Colors.blue.shade600,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Checking service status...',
              style: TextStyle(
                color: Colors.blue.shade700,
                fontSize: 14,
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
      loading: () => Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
        ),
        child: const LoadingWidget(
          message:
              'Loading items... This may take a moment if the service is starting up.',
          useShimmer: true,
        ),
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
      child: Container(
        margin: const EdgeInsets.all(28),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              filterState.hasFilters
                  ? FluentIcons.search_20_regular
                  : FluentIcons.box_20_regular,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 20),
            Text(
              filterState.hasFilters ? 'No items found' : 'No items available',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              filterState.hasFilters
                  ? 'Try adjusting filters or clearing them.'
                  : 'Check back later for new items.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7),
                  ),
              textAlign: TextAlign.center,
            ),
            if (filterState.hasFilters) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  textStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
                onPressed: () {
                  ref.read(filterStateProvider.notifier).state =
                      const FilterState();
                  ref.invalidate(itemsProvider);
                },
                icon: Icon(FluentIcons.dismiss_20_filled),
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade600,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              FluentIcons.box_20_filled,
              size: 18,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            '$itemCount item${itemCount == 1 ? '' : 's'} found',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green.shade600,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(FluentIcons.checkmark_20_filled, size: 16, color: Colors.white),
                const SizedBox(width: 6),
                Text(
                  'Updated',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
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
    IconData errorIcon = FluentIcons.error_circle_20_filled;

    if (error is Exception) {
      final errorStr = error.toString();
      if (errorStr.contains('DioException')) {
        try {
          final dioError = error as DioException;
          errorMessage = NetworkExceptions.getErrorMessage(dioError);
          if (NetworkExceptions.isNetworkError(dioError)) {
            errorIcon = FluentIcons.wifi_off_20_filled;
          }
        } catch (_) {
          errorMessage = 'Network error. Please check your connection.';
          errorIcon = FluentIcons.wifi_off_20_filled;
        }
      } else {
        errorMessage = errorStr.replaceFirst('Exception: ', '');
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
      ),
      child: CustomErrorWidget(
        message: errorMessage,
        icon: errorIcon,
        onRetry: () => _refreshData(context, ref),
      ),
    );
  }

  Future<void> _refreshData(BuildContext context, WidgetRef ref) async {
    ref.invalidate(itemsProvider);
    ref.invalidate(healthCheckProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Refreshing data...',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}

// MODERN FILTER BAR
class _ModernFilterBar extends ConsumerStatefulWidget {
  const _ModernFilterBar();

  @override
  ConsumerState<_ModernFilterBar> createState() => _ModernFilterBarState();
}

class _ModernFilterBarState extends ConsumerState<_ModernFilterBar> {
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

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 720;

          final categoryWidget = _ModernDropdown<String>(
            label: 'Category',
            value: state.category.isEmpty ? null : state.category,
            items: categories,
            onChanged: (val) {
              _applyFilters(category: val ?? '', subCategory: '');
            },
          );

          final subcategoryWidget = _ModernDropdown<String>(
            label: 'Subcategory',
            value: state.subCategory.isEmpty ? null : state.subCategory,
            items: subs,
            onChanged: (val) => _applyFilters(subCategory: val ?? ''),
          );

          final searchWidget = _ModernTextField(
            controller: _searchController,
            label: 'Search products...',
            hint: 'e.g., laptop, mobile, board games',
            onSubmitted: (v) => _applyFilters(search: v.trim()),
          );

          final clearButton = _ModernClearButton(
            hasFilters: state.hasFilters,
            onPressed: state.hasFilters
                ? () {
                    _searchController.clear();
                    _applyFilters(category: '', subCategory: '', search: '');
                  }
                : null,
          );

          if (isWide) {
            return Column(
              children: [
                Row(
                  children: [
                    Flexible(flex: 2, child: categoryWidget),
                    const SizedBox(width: 16),
                    if (state.category.isNotEmpty)
                      Flexible(flex: 2, child: subcategoryWidget),
                    if (state.category.isNotEmpty) const SizedBox(width: 16),
                    Flexible(flex: 3, child: searchWidget),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Spacer(),
                    clearButton,
                  ],
                ),
              ],
            );
          }

          return Column(
            children: [
              categoryWidget,
              const SizedBox(height: 16),
              if (state.category.isNotEmpty) subcategoryWidget,
              if (state.category.isNotEmpty) const SizedBox(height: 16),
              searchWidget,
              const SizedBox(height: 20),
              clearButton,
            ],
          );
        },
      ),
    );
  }
}

// MODERN DROPDOWN COMPONENT (WITH BLACK FONT COLORS)
class _ModernDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<T> items;
  final void Function(T?) onChanged;

  const _ModernDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: TextStyle(
              color: Colors.black, // ← BLACK LABEL COLOR
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
        DropdownButtonFormField<T>(
          isExpanded: true,
          value: value,
          icon: null, // Remove default icon
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white, // White background
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade400, width: 2), // Grey border
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade600, width: 2), // Darker grey on focus
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            hintText: 'Select $label',
            hintStyle: TextStyle(
              color: Colors.grey.shade600, // ← GREY HINT COLOR
              fontWeight: FontWeight.w500,
            ),
          ),
          style: TextStyle(
            color: Colors.black, // ← BLACK DROPDOWN TEXT COLOR
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
          items: items
              .map((e) => DropdownMenuItem<T>(
                    value: e,
                    child: Text(
                      e.toString(),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.black, // ← BLACK DROPDOWN ITEM COLOR
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

// MODERN TEXT FIELD COMPONENT (WITH BLACK FONT COLORS)
class _ModernTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final void Function(String) onSubmitted;

  const _ModernTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: TextStyle(
              color: Colors.black, // ← BLACK LABEL COLOR
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
        TextField(
          controller: controller,
          style: TextStyle(
            color: Colors.black, // ← BLACK TEXT INPUT COLOR
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white, // White background
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade400, width: 2), // Grey border
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade600, width: 2), // Darker grey on focus
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.grey.shade600, // ← GREY HINT COLOR
              fontWeight: FontWeight.w500,
            ),
            suffixIcon: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade200, // Grey icon background
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                FluentIcons.search_20_filled,
                color: Colors.grey.shade700, // Grey icon color
                size: 20,
              ),
            ),
          ),
          textInputAction: TextInputAction.search,
          onSubmitted: onSubmitted,
        ),
      ],
    );
  }
}

// MODERN CLEAR BUTTON COMPONENT
class _ModernClearButton extends StatelessWidget {
  final bool hasFilters;
  final VoidCallback? onPressed;

  const _ModernClearButton({
    required this.hasFilters,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: hasFilters ? 1.0 : 0.6,
      child: FilledButton.icon(
        style: FilledButton.styleFrom(
          backgroundColor: hasFilters ? Colors.red.shade600 : Colors.grey.shade400,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.shade400,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          elevation: hasFilters ? 4 : 0,
        ),
        onPressed: onPressed,
        icon: Icon(FluentIcons.dismiss_20_filled, size: 20),
        label: const Text('Clear Filters'),
      ),
    );
  }
}

// Background images
String _getBackgroundImageUrl(String category) {
  const Map<String, String> categoryImages = {
    'books': 'https://images.unsplash.com/photo-1481627834876-b7833e8f5570?auto=format&fit=crop&w=1400&q=80',
    'clothing': 'https://images.unsplash.com/photo-1445205170230-053b83016050?auto=format&fit=crop&w=1400&q=80',
    'electronics': 'https://images.unsplash.com/photo-1468495244123-6c6c332eeece?auto=format&fit=crop&w=1400&q=80',
    'fitness': 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?auto=format&fit=crop&w=1400&q=80',
    'sports': 'https://images.unsplash.com/photo-1461896836934-ffe607ba8211?auto=format&fit=crop&w=1400&q=80',
    'toys': 'https://images.unsplash.com/photo-1558618047-3c8c76ca7d13?auto=format&fit=crop&w=1400&q=80',
    'furniture': 'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?auto=format&fit=crop&w=1400&q=80',
    'food': 'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?auto=format&fit=crop&w=1400&q=80',
  };

  return categoryImages[category.toLowerCase()] ?? 
         'https://images.unsplash.com/photo-1441986300917-64674bd600d8?auto=format&fit=crop&w=1400&q=80';
}
