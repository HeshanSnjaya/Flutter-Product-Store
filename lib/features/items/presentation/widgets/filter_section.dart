import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/items_providers.dart';

class FilterSection extends ConsumerStatefulWidget {
  const FilterSection({super.key});

  @override
  ConsumerState<FilterSection> createState() => _FilterSectionState();
}

class _FilterSectionState extends ConsumerState<FilterSection> {
  final _categoryController = TextEditingController();
  final _subCategoryController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Initialize controllers with current filter state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final filterState = ref.read(filterStateProvider);
      _categoryController.text = filterState.category;
      _subCategoryController.text = filterState.subCategory;
    });
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _subCategoryController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    if (_formKey.currentState?.validate() ?? false) {
      final filterState = FilterState(
        category: _categoryController.text.trim(),
        subCategory: _subCategoryController.text.trim(),
      );
      
      ref.read(filterStateProvider.notifier).state = filterState;
      
      // Invalidate the items provider to trigger a refetch
      ref.invalidate(itemsProvider);
      
      // Show feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(filterState.hasFilters ? 'Filters applied' : 'Showing all items'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void _clearFilters() {
    _categoryController.clear();
    _subCategoryController.clear();
    
    ref.read(filterStateProvider.notifier).state = const FilterState();
    ref.invalidate(itemsProvider);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Filters cleared'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filterState = ref.watch(filterStateProvider);
    
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.filter_list,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Filter Items',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _categoryController,
                      decoration: InputDecoration(
                        labelText: 'Category',
                        hintText: 'e.g., Electronics',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.category),
                        suffixIcon: _categoryController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _categoryController.clear();
                                  setState(() {});
                                },
                              )
                            : null,
                      ),
                      textInputAction: TextInputAction.next,
                      onChanged: (value) => setState(() {}),
                      validator: (value) {
                        // Optional: Add validation if needed
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _subCategoryController,
                      decoration: InputDecoration(
                        labelText: 'Sub Category',
                        hintText: 'e.g., Phones',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.subdirectory_arrow_right),
                        suffixIcon: _subCategoryController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _subCategoryController.clear();
                                  setState(() {});
                                },
                              )
                            : null,
                      ),
                      textInputAction: TextInputAction.search,
                      onFieldSubmitted: (_) => _applyFilters(),
                      onChanged: (value) => setState(() {}),
                      validator: (value) {
                        // Optional: Add validation if needed
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _applyFilters,
                      icon: const Icon(Icons.search),
                      label: const Text('Apply Filters'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: filterState.hasFilters ? _clearFilters : null,
                      icon: const Icon(Icons.clear),
                      label: const Text('Clear'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
              if (filterState.hasFilters) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    if (filterState.category.isNotEmpty)
                      Chip(
                        label: Text('Category: ${filterState.category}'),
                        onDeleted: () {
                          _categoryController.clear();
                          _applyFilters();
                        },
                      ),
                    if (filterState.subCategory.isNotEmpty)
                      Chip(
                        label: Text('Sub: ${filterState.subCategory}'),
                        onDeleted: () {
                          _subCategoryController.clear();
                          _applyFilters();
                        },
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
