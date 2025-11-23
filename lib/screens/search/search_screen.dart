import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/items_provider.dart';
import '../../widgets/cards/item_card.dart';
import '../../widgets/common/empty_state.dart';
import '../../utils/constants/strings.dart';
import '../../utils/constants/colors.dart';
import '../../utils/theme/app_theme.dart';
import '../item_detail/item_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedType;
  int? _selectedYear;
  double? _minValue;
  double? _maxValue;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.searchTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: AppStrings.searchHint,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                          context.read<ItemsProvider>().clearFilters();
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
                if (value.length >= 2) {
                  context.read<ItemsProvider>().searchItems(value);
                } else if (value.isEmpty) {
                  context.read<ItemsProvider>().clearFilters();
                }
              },
            ),
          ),

          // Active Filters
          if (_hasActiveFilters()) _buildActiveFilters(),

          // Search Results
          Expanded(
            child: Consumer<ItemsProvider>(
              builder: (context, itemsProvider, child) {
                if (_searchQuery.isEmpty && !_hasActiveFilters()) {
                  return EmptyState(
                    icon: Icons.search,
                    title: 'Start Searching',
                    message: 'Enter a search term to find your items',
                  );
                }

                if (itemsProvider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (itemsProvider.items.isEmpty) {
                  return EmptyState(
                    icon: Icons.search_off,
                    title: AppStrings.searchNoResults,
                    message: 'Try adjusting your search or filters',
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(AppTheme.spacingM),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: AppTheme.spacingM,
                    mainAxisSpacing: AppTheme.spacingM,
                  ),
                  itemCount: itemsProvider.items.length,
                  itemBuilder: (context, index) {
                    final item = itemsProvider.items[index];
                    return ItemCard(
                      item: item,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ItemDetailScreen(
                              itemId: item.id,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  bool _hasActiveFilters() {
    return _selectedType != null ||
        _selectedYear != null ||
        _minValue != null ||
        _maxValue != null;
  }

  Widget _buildActiveFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          if (_selectedType != null)
            _buildFilterChip(
              label: 'Type: $_selectedType',
              onDeleted: () {
                setState(() {
                  _selectedType = null;
                });
                _applyFilters();
              },
            ),
          if (_selectedYear != null)
            _buildFilterChip(
              label: 'Year: $_selectedYear',
              onDeleted: () {
                setState(() {
                  _selectedYear = null;
                });
                _applyFilters();
              },
            ),
          if (_minValue != null || _maxValue != null)
            _buildFilterChip(
              label: 'Value: \$${_minValue ?? 0} - \$${_maxValue ?? "∞"}',
              onDeleted: () {
                setState(() {
                  _minValue = null;
                  _maxValue = null;
                });
                _applyFilters();
              },
            ),
          TextButton.icon(
            onPressed: _clearAllFilters,
            icon: const Icon(Icons.clear_all),
            label: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required VoidCallback onDeleted,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: AppTheme.spacingS),
      child: Chip(
        label: Text(label),
        onDeleted: onDeleted,
        deleteIcon: const Icon(Icons.close, size: 18),
      ),
    );
  }

  void _clearAllFilters() {
    setState(() {
      _selectedType = null;
      _selectedYear = null;
      _minValue = null;
      _maxValue = null;
    });
    context.read<ItemsProvider>().clearFilters();
    if (_searchQuery.isNotEmpty) {
      context.read<ItemsProvider>().searchItems(_searchQuery);
    }
  }

  void _applyFilters() {
    // TODO: Implement complex filtering with multiple criteria
    if (_selectedType != null) {
      context.read<ItemsProvider>().filterByType(_selectedType!);
    } else if (_selectedYear != null) {
      context.read<ItemsProvider>().filterByYear(_selectedYear!);
    } else if (_searchQuery.isNotEmpty) {
      context.read<ItemsProvider>().searchItems(_searchQuery);
    }
  }

  void _showFilterDialog() async {
    final itemsProvider = context.read<ItemsProvider>();
    final types = await itemsProvider.getAllTypes();
    final years = await itemsProvider.getAllYears();

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return StatefulBuilder(
            builder: (context, setModalState) {
              return Container(
                padding: const EdgeInsets.all(AppTheme.spacingL),
                child: ListView(
                  controller: scrollController,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Filters',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        TextButton(
                          onPressed: () {
                            setModalState(() {
                              _selectedType = null;
                              _selectedYear = null;
                              _minValue = null;
                              _maxValue = null;
                            });
                          },
                          child: const Text('Reset'),
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: AppTheme.spacingL),

                    // Type Filter
                    Text(
                      'Filter by Type',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppTheme.spacingS),
                    Wrap(
                      spacing: AppTheme.spacingS,
                      children: types.map((type) {
                        final isSelected = _selectedType == type;
                        return FilterChip(
                          label: Text(type),
                          selected: isSelected,
                          onSelected: (selected) {
                            setModalState(() {
                              _selectedType = selected ? type : null;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: AppTheme.spacingL),

                    // Year Filter
                    Text(
                      'Filter by Year',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppTheme.spacingS),
                    Wrap(
                      spacing: AppTheme.spacingS,
                      children: years.map((year) {
                        final isSelected = _selectedYear == year;
                        return FilterChip(
                          label: Text(year.toString()),
                          selected: isSelected,
                          onSelected: (selected) {
                            setModalState(() {
                              _selectedYear = selected ? year : null;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: AppTheme.spacingXl),

                    // Apply Button
                    ElevatedButton(
                      onPressed: () {
                        setState(() {}); // Update main screen state
                        Navigator.pop(context);
                        _applyFilters();
                      },
                      child: const Text('Apply Filters'),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
