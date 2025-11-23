import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/items_provider.dart';
import '../../providers/lists_provider.dart';
import '../../models/item.dart';
import '../../widgets/cards/item_card.dart';
import '../../utils/constants/colors.dart';
import '../../utils/theme/app_theme.dart';

class BulkOperationsScreen extends StatefulWidget {
  final String listId;

  const BulkOperationsScreen({
    super.key,
    required this.listId,
  });

  @override
  State<BulkOperationsScreen> createState() => _BulkOperationsScreenState();
}

class _BulkOperationsScreenState extends State<BulkOperationsScreen> {
  final Set<String> _selectedItemIds = {};
  bool _selectAll = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ItemsProvider>().loadItemsByListId(widget.listId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Items (${_selectedItemIds.length})'),
        actions: [
          TextButton(
            onPressed: _toggleSelectAll,
            child: Text(_selectAll ? 'Deselect All' : 'Select All'),
          ),
        ],
      ),
      body: Consumer<ItemsProvider>(
        builder: (context, itemsProvider, child) {
          if (itemsProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = itemsProvider.items;

          if (items.isEmpty) {
            return const Center(
              child: Text('No items in this list'),
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
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final isSelected = _selectedItemIds.contains(item.id);

              return GestureDetector(
                onTap: () => _toggleSelection(item.id),
                child: Stack(
                  children: [
                    ItemCard(
                      item: item,
                      onTap: () => _toggleSelection(item.id),
                    ),
                    
                    // Selection overlay
                    if (isSelected)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(AppTheme.radiusM),
                            border: Border.all(
                              color: AppColors.primary,
                              width: 3,
                            ),
                          ),
                        ),
                      ),
                    
                    // Checkbox
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Checkbox(
                          value: isSelected,
                          onChanged: (value) => _toggleSelection(item.id),
                          activeColor: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: _selectedItemIds.isNotEmpty
          ? _buildBottomBar()
          : null,
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _showMoveDialog,
                icon: const Icon(Icons.drive_file_move),
                label: const Text('Move'),
              ),
            ),
            const SizedBox(width: AppTheme.spacingM),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _showDeleteConfirmation,
                icon: const Icon(Icons.delete),
                label: const Text('Delete'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleSelection(String itemId) {
    setState(() {
      if (_selectedItemIds.contains(itemId)) {
        _selectedItemIds.remove(itemId);
      } else {
        _selectedItemIds.add(itemId);
      }
      _updateSelectAllState();
    });
  }

  void _toggleSelectAll() {
    setState(() {
      final itemsProvider = context.read<ItemsProvider>();
      if (_selectAll) {
        _selectedItemIds.clear();
      } else {
        _selectedItemIds.addAll(
          itemsProvider.items.map((item) => item.id),
        );
      }
      _selectAll = !_selectAll;
    });
  }

  void _updateSelectAllState() {
    final itemsProvider = context.read<ItemsProvider>();
    setState(() {
      _selectAll = _selectedItemIds.length == itemsProvider.items.length;
    });
  }

  void _showMoveDialog() async {
    final listsProvider = context.read<ListsProvider>();
    await listsProvider.loadLists();
    
    final availableLists = listsProvider.lists
        .where((list) => list.id != widget.listId)
        .toList();

    if (availableLists.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No other lists available to move items to'),
        ),
      );
      return;
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Move Items'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Select a list to move ${_selectedItemIds.length} items to:'),
            const SizedBox(height: AppTheme.spacingM),
            ...availableLists.map((list) {
              return ListTile(
                title: Text(list.name),
                subtitle: Text('${list.itemCount} items'),
                onTap: () {
                  Navigator.pop(context);
                  _moveItems(list.id);
                },
              );
            }),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _moveItems(String targetListId) async {
    final itemsProvider = context.read<ItemsProvider>();
    
    // TODO: Implement move functionality in provider
    // For now, show a message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Moving ${_selectedItemIds.length} items...'),
      ),
    );

    // Clear selection and go back
    setState(() {
      _selectedItemIds.clear();
    });
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Items'),
        content: Text(
          'Are you sure you want to delete ${_selectedItemIds.length} items? '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteSelectedItems();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteSelectedItems() async {
    final itemsProvider = context.read<ItemsProvider>();
    
    for (final itemId in _selectedItemIds) {
      await itemsProvider.deleteItem(itemId);
    }

    setState(() {
      _selectedItemIds.clear();
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Items deleted successfully'),
        ),
      );
      
      // Go back to list screen
      Navigator.pop(context);
    }
  }
}
