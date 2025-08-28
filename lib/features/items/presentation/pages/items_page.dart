import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/network_exceptions.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../widgets/error_widget.dart';
import '../widgets/item_card.dart';
import '../widgets/filter_section.dart';
import '../providers/items_providers.dart';

class ItemsPage extends ConsumerWidget {
  const ItemsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final healthCheck = ref.watch(healthCheckProvider);
    final items = ref.watch(itemsProvider);
    final filterState = ref.watch(filterStateProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: _buildAppBar(context, ref),
      body: Column(
        children: [
          _buildHealthBanner(healthCheck),
          
          const FilterSection()
            .animate()
            .fadeIn(duration: 400.ms, delay: 100.ms)
            .slideY(begin: -0.2, end: 0, duration: 400.ms),

          Expanded(
            child: _buildItemsContent(context, ref, items, filterState),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(context, ref),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, WidgetRef ref) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 0,
      scrolledUnderElevation: 1,
      centerTitle: true,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.store_rounded,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          const Text('Thrive360 Store'),
        ],
      ),
      actions: [
        IconButton(
          tooltip: 'Refresh',
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
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

  Widget _buildHealthBanner(AsyncValue<bool> healthCheck) {
    return healthCheck.when(
      data: (isHealthy) {
        if (!isHealthy) {
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(16),
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
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Service Warming Up',
                        style: TextStyle(
                          color: Colors.amber.shade800,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'First request may take longer than usual.',
                        style: TextStyle(
                          color: Colors.amber.shade700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
          .animate()
          .fadeIn(duration: 300.ms)
          .slideY(begin: -0.5, end: 0, duration: 300.ms);
        }
        return const SizedBox.shrink();
      },
      loading: () => Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Row(
          children: [
            SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.blue.shade600,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Checking service status...',
              style: TextStyle(
                color: Colors.blue.shade700,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      )
      .animate()
      .fadeIn(duration: 300.ms)
      .slideY(begin: -0.5, end: 0, duration: 300.ms),
      error: (error, _) => const SizedBox.shrink(),
    );
  }

  Widget _buildItemsContent(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List> items,
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
              
              Expanded(
                child: _buildResponsiveItemsList(context, itemsList),
              ),
            ],
          ),
        );
      },
      loading: () => const LoadingWidget(
        message: 'Loading items...\n\nThis may take a moment if the service is starting up.',
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
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                filterState.hasFilters 
                  ? Icons.search_off_rounded 
                  : Icons.inventory_2_outlined,
                size: 48,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              filterState.hasFilters
                ? 'No items found'
                : 'No items available',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              filterState.hasFilters
                ? 'Try adjusting your filters or check back later'
                : 'Check back later for new items',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            if (filterState.hasFilters) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () {
                  ref.read(filterStateProvider.notifier).state = const FilterState();
                  ref.invalidate(itemsProvider);
                },
                icon: const Icon(Icons.clear_all_rounded),
                label: const Text('Clear Filters'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ],
        ),
      ),
    )
    .animate()
    .fadeIn(duration: 400.ms)
    .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0));
  }

  Widget _buildItemsCountHeader(BuildContext context, int itemCount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
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
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
          const Spacer(),
          if (itemCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Updated',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    )
    .animate()
    .fadeIn(duration: 300.ms, delay: 200.ms)
    .slideX(begin: -0.2, end: 0, duration: 300.ms);
  }

  Widget _buildResponsiveItemsList(BuildContext context, List itemsList) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          final crossAxisCount = constraints.maxWidth > 1200 ? 3 : 2;
          
          return GridView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
        } catch (e) {
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
        content: const Row(
          children: [
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
