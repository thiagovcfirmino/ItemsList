import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/lists_provider.dart';
import '../../providers/items_provider.dart';
import '../../widgets/cards/item_card.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../utils/constants/strings.dart';
import '../../utils/constants/colors.dart';
import '../../utils/theme/app_theme.dart';
import '../../models/enums.dart';
import '../item_detail/item_detail_screen.dart';
import '../item_form/item_form_screen.dart';
import '../bulk_operations/bulk_operations_screen.dart';

class ListDetailScreen extends StatefulWidget {
  final String listId;

  const ListDetailScreen({
    super.key,
    required this.listId,
  });

  @override
  State<ListDetailScreen> createState() => _ListDetailScreenState();
}

class _ListDetailScreenState extends State<ListDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadItems();
    });
  }

  Future<void> _loadItems() async {
    final itemsProvider = context.read<ItemsProvider>();
    await itemsProvider.loadItemsByListId(widget.listId);
  }

  @override
  Widget build(BuildContext context) {
    final listsProvider = context.watch<ListsProvider>();
    final list = listsProvider.getListById(widget.listId);

    if (list == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: Text('List not found'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(list.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.checklist),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BulkOperationsScreen(
                    listId: widget.listId,
                  ),
                ),
              ).then((_) => _loadItems());
            },
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortOptions,
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit),
                    SizedBox(width: 8),
                    Text(AppStrings.listEdit),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: AppColors.error),
                    SizedBox(width: 8),
                    Text(
                      AppStrings.listDelete,
                      style: TextStyle(color: AppColors.error),
                    ),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'edit') {
                _showEditListDialog(list.name, list.description);
              } else if (value == 'delete') {
                _showDeleteListDialog();
              }
            },
          ),
        ],
      ),
      body: Consumer<ItemsProvider>(
        builder: (context, itemsProvider, child) {
          if (itemsProvider.isLoading) {
            return const LoadingIndicator();
          }

          if (itemsProvider.items.isEmpty) {
            return EmptyState(
              icon: Icons.inventory_2_outlined,
              title: AppStrings.listEmptyTitle,
              message: AppStrings.listEmptyMessage,
              actionLabel: AppStrings.listAddItem,
              onAction: _navigateToAddItem,
            );
          }

          return RefreshIndicator(
            onRefresh: _loadItems,
            child: GridView.builder(
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
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddItem,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _navigateToAddItem() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ItemFormScreen(
          listId: widget.listId,
        ),
      ),
    ).then((_) => _loadItems());
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.sort_by_alpha),
              title: const Text('Name (A-Z)'),
              onTap: () {
                context.read<ItemsProvider>().sortItems(
                      SortOption.nameAsc,
                    );
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.sort_by_alpha),
              title: const Text('Name (Z-A)'),
              onTap: () {
                context.read<ItemsProvider>().sortItems(
                      SortOption.nameDesc,
                    );
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Newest First'),
              onTap: () {
                context.read<ItemsProvider>().sortItems(
                      SortOption.dateDesc,
                    );
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Oldest First'),
              onTap: () {
                context.read<ItemsProvider>().sortItems(
                      SortOption.dateAsc,
                    );
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditListDialog(String currentName, String? currentDescription) {
    final nameController = TextEditingController(text: currentName);
    final descriptionController = TextEditingController(
      text: currentDescription ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit List'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'List Name'),
              autofocus: true,
            ),
            const SizedBox(height: AppTheme.spacingM),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.formCancel),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) return;

              final listsProvider = context.read<ListsProvider>();
              await listsProvider.updateList(
                id: widget.listId,
                name: nameController.text.trim(),
                description: descriptionController.text.trim().isEmpty
                    ? null
                    : descriptionController.text.trim(),
              );

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(AppStrings.messageListUpdated),
                  ),
                );
              }
            },
            child: const Text(AppStrings.formSave),
          ),
        ],
      ),
    );
  }

  void _showDeleteListDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.dialogDeleteTitle),
        content: const Text(AppStrings.dialogDeleteListMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.dialogCancel),
          ),
          ElevatedButton(
            onPressed: () async {
              final listsProvider = context.read<ListsProvider>();
              await listsProvider.deleteList(widget.listId);

              if (context.mounted) {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Return to home
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(AppStrings.messageListDeleted),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text(AppStrings.dialogConfirm),
          ),
        ],
      ),
    );
  }
}
